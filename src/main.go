// Go + Distroless Example
// Ultra-lightweight Go application with distroless containers
//
// Author: Alan Ramalho (@raioramalho)
// Email: ramalho.sit@gmail.com
// Role: Sênior Solutions Architect
// License: MIT
// Repository: https://github.com/raioramalho/go-distroless-example

package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/health", handleHealth)

	log.Printf("Servidor iniciando na porta %s...", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello from Go + Distroless! 🔥\n")
	fmt.Fprintf(w, "Path: %s\n", r.URL.Path)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "OK")
}


