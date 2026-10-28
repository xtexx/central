package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"time"

	"github.com/mmcdole/gofeed"
)

type linkdingBookmark struct {
	ID           int64     `json:"id"`
	URL          string    `json:"url"`
	Title        string    `json:"title"`
	Description  string    `json:"description"`
	Notes        string    `json:"notes"`
	TagNames     []string  `json:"tag_names"`
	DateAdded    time.Time `json:"date_added"`
	DateModified time.Time `json:"date_modified"`
}

type linkdingResponse struct {
	Count   int                `json:"count"`
	Next    string             `json:"next"`
	Results []linkdingBookmark `json:"results"`
}

func fetchLinkdingFeed(baseURL, token string, limit int) (*gofeed.Feed, error) {
	client := &http.Client{
		Timeout: time.Duration(k.Int64("client_timeout_seconds")) * time.Second,
	}
	endpoint, err := url.Parse(baseURL)
	if err != nil {
		return nil, err
	}
	endpoint.Path = "/api/bookmarks/"
	query := endpoint.Query()
	query.Set("shared", "yes")
	pageSize := limit
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 100
	}
	query.Set("limit", fmt.Sprint(pageSize))
	endpoint.RawQuery = query.Encode()

	feed := &gofeed.Feed{
		Title:       "linkding user shared bookmarks",
		Link:        baseURL,
		Description: "User shared bookmarks from " + baseURL,
	}
	for endpoint != nil && (limit <= 0 || len(feed.Items) < limit) {
		req, err := http.NewRequest("GET", endpoint.String(), nil)
		if err != nil {
			return nil, err
		}
		req.Header.Set("Authorization", "Bearer "+token)
		resp, err := client.Do(req)
		if err != nil {
			return nil, err
		}
		if resp.StatusCode != http.StatusOK {
			resp.Body.Close()
			return nil, fmt.Errorf("linkding API returned %s", resp.Status)
		}
		var page linkdingResponse
		err = json.NewDecoder(resp.Body).Decode(&page)
		resp.Body.Close()
		if err != nil {
			return nil, err
		}
		for _, bm := range page.Results {
			content := bm.Description
			if bm.Notes != "" {
				if content != "" {
					content += "\n\n"
				}
				content += bm.Notes
			}
			item := &gofeed.Item{
				GUID:            fmt.Sprint(bm.ID),
				Title:           bm.Title,
				Link:            bm.URL,
				Description:     content,
				PublishedParsed: &bm.DateAdded,
				UpdatedParsed:   &bm.DateModified,
			}
			for _, tag := range bm.TagNames {
				item.Categories = append(item.Categories, tag)
			}
			feed.Items = append(feed.Items, item)
		}
		next := page.Next
		endpoint = nil
		if next != "" && (limit <= 0 || len(feed.Items) < limit) {
			u, err := url.Parse(next)
			if err == nil {
				endpoint = u
			}
		}
	}
	return feed, nil
}

func fetchLinkding(fc *FeedConfig) {
	log.Printf("Fetching Linkding: %v\n", fc.LinkdingURL)
	feed, err := fetchLinkdingFeed(fc.LinkdingURL, fc.LinkdingToken, fc.Limit)
	if err != nil {
		log.Printf("Error on Linkding fetch: %v (%v)", fc.LinkdingURL, err)
		return
	}
	fc.Feed = feed
}
