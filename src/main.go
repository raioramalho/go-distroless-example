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

	"github.com/joho/godotenv"
)

func init() {
	// Carrega variáveis do arquivo .env (se existir)
	// Em produção (distroless), o .env não existe, usa variáveis de ambiente
	if err := godotenv.Load(); err != nil {
		log.Println("Arquivo .env não encontrado, usando variáveis de ambiente")
	}
}

func main() {
	port := getEnv("PORT", "8080")
	env := getEnv("GO_ENV", "development")

	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/health", handleHealth)

	log.Printf("🚀 Servidor iniciando na porta %s (env: %s)", port, env)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

// getEnv retorna o valor da variável de ambiente ou o valor padrão
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello from Go + Distroless! 🔥\n")
	fmt.Fprintf(w, "Path: %s\n", r.URL.Path)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "OK")
}


