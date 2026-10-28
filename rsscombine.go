package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"sort"
	"sync"
	"time"

	"github.com/gorilla/feeds"
	"github.com/knadh/koanf/parsers/yaml"
	"github.com/knadh/koanf/providers/confmap"
	"github.com/knadh/koanf/providers/file"
	"github.com/knadh/koanf/v2"
	"github.com/mmcdole/gofeed"
)

var k = koanf.NewWithConf(koanf.Conf{Delim: "/"})

func fetchUrl(fc *FeedConfig) {
	log.Printf("Fetching URL: %v\n", fc.URL)
	fp := gofeed.NewParser()
	fp.Client = &http.Client{
		Timeout: time.Duration(k.Int64("client_timeout_seconds")) * time.Second,
	}
	feed, err := fp.ParseURL(fc.URL)
	if err != nil {
		log.Printf("Error on URL: %v (%v)", fc.URL, err)
		return
	}
	fc.Feed = feed
}

type FeedConfig struct {
	URL            string
	OverrideAuthor string
	Feed           *gofeed.Feed
}

func fetchUrls(fc []*FeedConfig) {
	var wg sync.WaitGroup
	for _, feed := range fc {
		wg.Add(1)
		go func(fc *FeedConfig) {
			defer wg.Done()
			fetchUrl(fc)
		}(feed)
	}
	wg.Wait()
}

// TODO: there must be a shorter syntax for this
type byPublished []*FeedConfig

func (s byPublished) Len() int {
	return len(s)
}

func (s byPublished) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

func (s byPublished) Less(i, j int) bool {
	if s[i].Feed == nil {
		return false
	}
	if s[j].Feed == nil {
		return true
	}
	date1 := s[i].Feed.Items[0].PublishedParsed
	if date1 == nil {
		date1 = s[i].Feed.Items[0].UpdatedParsed
	}
	date2 := s[j].Feed.Items[0].PublishedParsed
	if date2 == nil {
		date2 = s[j].Feed.Items[0].UpdatedParsed
	}
	return date1.Before(*date2)
}

func getAuthor(feed *gofeed.Feed, item *gofeed.Item) *gofeed.Person {
	if len(feed.Authors) != 0 {
		return feed.Authors[0]
	}
	if len(item.Authors) != 0 {
		return item.Authors[0]
	}
	log.Printf("Could not determine author for %v", feed.Link)
	return &gofeed.Person{
		Name: k.String("default_author_name"),
	}
}

func combineFeeds(fcs []*FeedConfig) *feeds.Feed {
	feed := &feeds.Feed{
		Title:       k.String("title"),
		Link:        &feeds.Link{Href: k.String("link")},
		Description: k.String("description"),
		Author: &feeds.Author{
			Name:  k.String("author_name"),
			Email: k.String("author_email"),
		},
		Created: time.Now(),
	}
	sort.Sort(sort.Reverse(byPublished(fcs)))
	limit_per_feed := k.Int("feed_limit_per_feed")
	limit_all := k.Int("feed_limit")
	seen := make(map[string]bool)
	for _, fc := range fcs {
		if fc.Feed == nil {
			continue
		}
		for i, item := range fc.Feed.Items {
			if i > limit_per_feed {
				break
			}
			if len(item.Links) > 0 {
				item.Link = item.Links[0]
			}
			if seen[item.Link] {
				fmt.Printf("seen link \"%s\" for item %s\n", item.Link, item.Title)
				continue
			}
			created := item.PublishedParsed
			if created == nil {
				created = item.UpdatedParsed
			}
			author := getAuthor(fc.Feed, item)
			if len(fc.OverrideAuthor) != 0 {
				author = &gofeed.Person{
					Name: fc.OverrideAuthor,
				}
			}
			feed.Items = append(feed.Items, &feeds.Item{
				Title:       item.Title,
				Link:        &feeds.Link{Href: item.Link},
				Description: item.Description,
				Author:      &feeds.Author{Name: author.Name, Email: author.Email},
				Created:     *created,
				Content:     item.Content,
				Id:          item.Link,
				Updated:     *item.UpdatedParsed,
			})
			seen[item.Link] = true
		}
	}
	// Sort items by created date
	feed.Sort(func(a, b *feeds.Item) bool {
		return a.Created.After(b.Created)
	})
	// Only keep first set of items
	limit_all = min(len(feed.Items), limit_all)
	feed.Items = feed.Items[:limit_all]
	return feed
}

func GetAtomFeed() *feeds.Feed {
	feeds := make([]*FeedConfig, 0)
	for _, cfg := range k.Slices("feeds") {
		var fc FeedConfig
		fc.URL = cfg.String("url")
		fc.Feed = nil
		fc.OverrideAuthor = cfg.String("override_author")
		feeds = append(feeds, &fc)
	}
	fetchUrls(feeds)
	combinedFeed := combineFeeds(feeds)
	return combinedFeed
}

func LoadConfig() {
	configFile, ok := os.LookupEnv("RSSCOMBINE_CONFIG")
	if !ok {
		configFile = "rsscombine.yml"
	}
	k.Load(confmap.Provider(map[string]any{
		"default_author_name":    "Unknown Author",
		"client_timeout_seconds": "60",
		"feed_limit_per_feed":    "20",
		"feed_limit":             "20",
	}, "/"), nil)
	k.Load(file.Provider(configFile), yaml.Parser())
}

func main() {
	LoadConfig()
	combinedFeed := GetAtomFeed()
	atom, _ := combinedFeed.ToAtom()
	log.Printf("Rendered RSS with %v items", len(combinedFeed.Items))
	if k.String("output") != "" {
		if err := os.WriteFile(k.String("output"), []byte(atom), 0666); err != nil {
			log.Fatal(err)
		}
	} else {
		fmt.Println(atom)
	}
	return
}
