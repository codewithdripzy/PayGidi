package httpclient

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

type Client struct {
	baseURL    string
	client     *http.Client
	headers    http.Header
	rawHeaders map[string]string
}

type Option func(*Client)

type Response struct {
	StatusCode int
	Header     http.Header
	Body       []byte
}

type HTTPError struct {
	StatusCode int
	Body       []byte
}

func (e *HTTPError) Error() string {
	if len(e.Body) == 0 {
		return fmt.Sprintf("http request failed with status %d", e.StatusCode)
	}

	return fmt.Sprintf("http request failed with status %d: %s", e.StatusCode, string(e.Body))
}

func New(baseURL string, opts ...Option) *Client {
	c := &Client{
		baseURL:    strings.TrimRight(baseURL, "/"),
		client:     &http.Client{Timeout: 30 * time.Second},
		headers:    make(http.Header),
		rawHeaders: make(map[string]string),
	}

	for _, opt := range opts {
		opt(c)
	}

	return c
}

func WithHTTPClient(httpClient *http.Client) Option {
	return func(c *Client) {
		if httpClient != nil {
			c.client = httpClient
		}
	}
}

func WithTimeout(timeout time.Duration) Option {
	return func(c *Client) {
		if timeout > 0 {
			c.client.Timeout = timeout
		}
	}
}

func WithHeader(key, value string) Option {
	return func(c *Client) {
		c.headers.Set(key, value)
	}
}

func WithBearerToken(token string) Option {
	return func(c *Client) {
		if token != "" {
			c.headers.Set("Authorization", "Bearer "+token)
		}
	}
}

func (c *Client) WithHeader(key, value string) *Client {
	c.headers.Set(key, value)
	return c
}

func (c *Client) WithRawHeader(key, value string) *Client {
	c.rawHeaders[key] = value
	return c
}

func (c *Client) WithBearerToken(token string) *Client {
	if token != "" {
		c.headers.Set("Authorization", "Bearer "+token)
	}

	return c
}

func (c *Client) WithTimeout(timeout time.Duration) *Client {
	if timeout > 0 {
		c.client.Timeout = timeout
	}

	return c
}

func Get[T any](c *Client, ctx context.Context, path string, out *T) (*Response, error) {
	return c.DoJSON(ctx, http.MethodGet, path, nil, out)
}

func (c *Client) PutJSON(ctx context.Context, path string, body any, out any) (*Response, error) {
	return c.DoJSON(ctx, http.MethodPut, path, body, out)
}

func PostJSON[T any](c *Client, ctx context.Context, path string, body any, out *T) (*Response, error) {
	return c.DoJSON(ctx, http.MethodPost, path, body, out)
}

func PutJSON[T any](c *Client, ctx context.Context, path string, body any, out *T) (*Response, error) {
	return c.DoJSON(ctx, http.MethodPut, path, body, out)
}

func (c *Client) PatchJSON(ctx context.Context, path string, body any, out any) (*Response, error) {
	return c.DoJSON(ctx, http.MethodPatch, path, body, out)
}

func PatchJSON[T any](c *Client, ctx context.Context, path string, body any, out *T) (*Response, error) {
	return c.DoJSON(ctx, http.MethodPatch, path, body, out)
}

func (c *Client) Delete(ctx context.Context, path string, out any) (*Response, error) {
	return c.DoJSON(ctx, http.MethodDelete, path, nil, out)
}

func Delete[T any](c *Client, ctx context.Context, path string, out *T) (*Response, error) {
	return c.DoJSON(ctx, http.MethodDelete, path, nil, out)
}

func (c *Client) DoJSON(ctx context.Context, method, path string, body any, out any) (*Response, error) {
	var payload io.Reader
	if body != nil {
		encodedBody, err := json.Marshal(body)
		if err != nil {
			return nil, err
		}

		payload = bytes.NewBuffer(encodedBody)
	}

	req, err := http.NewRequestWithContext(ctx, method, c.resolveURL(path), payload)
	if err != nil {
		return nil, err
	}

	for key, values := range c.headers {
		for _, value := range values {
			req.Header.Add(key, value)
		}
	}

	for key, value := range c.rawHeaders {
		if strings.TrimSpace(key) == "" {
			continue
		}

		req.Header[key] = []string{value}
	}

	if body != nil && req.Header.Get("Content-Type") == "" {
		req.Header.Set("Content-Type", "application/json")
	}

	res, err := c.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()

	bodyBytes, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	response := &Response{
		StatusCode: res.StatusCode,
		Header:     res.Header.Clone(),
		Body:       bodyBytes,
	}

	if res.StatusCode < http.StatusOK || res.StatusCode >= http.StatusMultipleChoices {
		return response, &HTTPError{StatusCode: res.StatusCode, Body: bodyBytes}
	}

	if out != nil && len(bodyBytes) > 0 {
		if err := json.Unmarshal(bodyBytes, out); err != nil {
			return response, err
		}
	}

	return response, nil
}

func (r *Response) JSON(out any) error {
	if out == nil || len(r.Body) == 0 {
		return nil
	}

	return json.Unmarshal(r.Body, out)
}

func (c *Client) resolveURL(path string) string {
	if strings.HasPrefix(path, "http://") || strings.HasPrefix(path, "https://") {
		return path
	}

	if c.baseURL == "" {
		return path
	}

	return c.baseURL + "/" + strings.TrimLeft(path, "/")
}

func (c *Client) Headers() http.Header {
	if c == nil {
		return http.Header{}
	}

	headers := c.headers.Clone()
	for key, value := range c.rawHeaders {
		headers[key] = []string{value}
	}

	return headers
}
