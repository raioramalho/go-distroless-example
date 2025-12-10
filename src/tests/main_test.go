package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHandleRoot(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(handleRoot)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler retornou status errado: got %v want %v",
			status, http.StatusOK)
	}

	expected := "Hello from Go + Distroless! 🥑\n"
	if rr.Body.String()[:len(expected)] != expected {
		t.Errorf("handler retornou body inesperado: got %v want %v",
			rr.Body.String(), expected)
	}
}

func TestHandleHealth(t *testing.T) {
	req, err := http.NewRequest("GET", "/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(handleHealth)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler retornou status errado: got %v want %v",
			status, http.StatusOK)
	}

	expected := "OK"
	if rr.Body.String() != expected {
		t.Errorf("handler retornou body inesperado: got %v want %v",
			rr.Body.String(), expected)
	}
}

