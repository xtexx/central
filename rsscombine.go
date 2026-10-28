package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"sort"
	"time"

	"github.com/gorilla/feeds"
	"github.com/mmcdole/gofeed"
	"github.com/spf13/viper"
)

func getUrls() []string {
	return viper.GetStringSlice("feeds")
}

func fetchUrl(url string, ch chan<- *gofeed.Feed) {
	log.Printf("Fetching URL: %v\n", url)
	fp := gofeed.NewParser()
	fp.Client = &http.Client{
		Timeout: time.Duration(viper.GetInt("client_timeout_seconds")) * time.Second,
	}
	feed, err := fp.ParseURL(url)
	if err == nil {
		ch <- feed
	} else {
		log.Printf("Error on URL: %v (%v)", url, err)
		ch <- nil
	}
}

func fetchUrls(urls []string) []*gofeed.Feed {
	allFeeds := make([]*gofeed.Feed, 0)
	ch := make(chan *gofeed.Feed)
	for _, url := range urls {
		go fetchUrl(url, ch)
	}
	for range urls {
		feed := <-ch
		if feed != nil {
			allFeeds = append(allFeeds, feed)
		}
	}
	return allFeeds
}

// TODO: there must be a shorter syntax for this
type byPublished []*gofeed.Feed

func (s byPublished) Len() int {
	return len(s)
}

func (s byPublished) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

func (s byPublished) Less(i, j int) bool {
	date1 := s[i].Items[0].PublishedParsed
	if date1 == nil {
		date1 = s[i].Items[0].UpdatedParsed
	}
	date2 := s[j].Items[0].PublishedParsed
	if date2 == nil {
		date2 = s[j].Items[0].UpdatedParsed
	}
	return date1.Before(*date2)
}

func getAuthor(feed *gofeed.Feed) string {
	if feed.Author != nil {
		return feed.Author.Name
	}
	if feed.Items[0].Author != nil {
		return feed.Items[0].Author.Name
	}
	log.Printf("Could not determine author for %v", feed.Link)
	return viper.GetString("default_author_name")
}

func combineallFeeds(allFeeds []*gofeed.Feed) *feeds.Feed {
	feed := &feeds.Feed{
		Title:       viper.GetString("title"),
		Link:        &feeds.Link{Href: viper.GetString("link")},
		Description: viper.GetString("description"),
		Author: &feeds.Author{
			Name:  viper.GetString("author_name"),
			Email: viper.GetString("author_email"),
		},
		Created: time.Now(),
	}
	sort.Sort(sort.Reverse(byPublished(allFeeds)))
	limit_per_feed := viper.GetInt("feed_limit_per_feed")
	limit_all := viper.GetInt("feed_limit")
	seen := make(map[string]bool)
	for _, sourceFeed := range allFeeds {
		for i, item := range sourceFeed.Items {
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
			feed.Items = append(feed.Items, &feeds.Item{
				Title:       item.Title,
				Link:        &feeds.Link{Href: item.Link},
				Description: item.Description,
				Author:      &feeds.Author{Name: getAuthor(sourceFeed)},
				Created:     *created,
				Content:     item.Content,
				Id:          item.Link,
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
	urls := getUrls()
	allFeeds := fetchUrls(urls)
	combinedFeed := combineallFeeds(allFeeds)
	return combinedFeed
}

func LoadConfig() {
	configFile, ok := os.LookupEnv("RSSCOMBINE_CONFIG")
	if ok {
		viper.SetConfigFile(configFile)
	} else {
		viper.SetConfigName("rsscombine")
	}
	viper.AddConfigPath(".")
	viper.SetEnvPrefix("RSSCOMBINE")
	viper.AutomaticEnv()
	viper.SetDefault("default_author_name", "Unknown Author")
	viper.SetDefault("client_timeout_seconds", "60")
	viper.SetDefault("feed_limit_per_feed", "20")
	viper.SetDefault("feed_limit", "20")
	err := viper.ReadInConfig()
	if err != nil {
		panic(fmt.Errorf("Fatal error config file: %s \n", err))
	}
}

func main() {
	LoadConfig()
	combinedFeed := GetAtomFeed()
	atom, _ := combinedFeed.ToAtom()
	log.Printf("Rendered RSS with %v items", len(combinedFeed.Items))
	if viper.GetString("output") != "" {
		if err := os.WriteFile(viper.GetString("output"), []byte(atom), 0666); err != nil {
			log.Fatal(err)
		}
	} else {
		fmt.Println(atom)
	}
	return
}
