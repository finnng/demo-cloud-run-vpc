package main

import (
	"io"
	"log/slog"
	"net/http"
	"os"
)

var backendPort = os.Getenv("BACKEND_PORT")

func main() {
	if backendPort == "" {
		backendPort = "8080"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		slog.Info("Request received", "path", r.URL.Path)
		w.Write([]byte("This is backend"))
	})

	mux.HandleFunc("GET /api/hello", func(w http.ResponseWriter, r *http.Request) {
		slog.Info("Request received", "path", r.URL.Path)


		resp, err := http.Get("https://example.com/")
		if err != nil {
			slog.Error("Error calling weather https endpoint", "error", err)
			w.Write([]byte(err.Error()))
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		defer resp.Body.Close()

		respBody, err := io.ReadAll(resp.Body)
		if err != nil {
			slog.Error("Error reading website response", "error", err)
			w.Write([]byte(err.Error()))
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		slog.Info("Response body", "data", string(respBody))

		w.WriteHeader(http.StatusOK)
		w.Write(respBody)
	})

	slog.Info("Server started on port " + backendPort)
	http.ListenAndServe(":"+backendPort, mux)

}
