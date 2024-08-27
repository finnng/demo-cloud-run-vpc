package main

import (
	"io"
	"log/slog"
	"net/http"
	"os"
)

var backendUrl = os.Getenv("BACKEND_URL")
var frontendPort = os.Getenv("FRONTEND_PORT")

func main() {
	if backendUrl == "" {
		backendUrl = "http://localhost:8080"
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = frontendPort
	}
	slog.Info("Backend URL", "url", backendUrl)

	mux := http.NewServeMux()

	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		slog.Info("Request received", "path", r.URL.Path)
		w.Write([]byte("Hello World"))
	})

	mux.HandleFunc("GET /request-backend", func(w http.ResponseWriter, r *http.Request) {
		slog.Info("Request received", "path", r.URL.Path)
		resp, err := http.Get(backendUrl + "/api/hello")
		if err != nil {
			slog.Error("Error calling backend", "error", err)
			w.Write([]byte(err.Error()))
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		defer resp.Body.Close()

		for key, values := range resp.Header {
			for _, value := range values {
				w.Header().Add(key, value)
			}
		}

		w.WriteHeader(resp.StatusCode)
		io.Copy(w, resp.Body)
	})

	slog.Info("Server started on port " + port)
	http.ListenAndServe(":"+port, mux)
}
