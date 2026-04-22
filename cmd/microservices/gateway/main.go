package main

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"

	"github.com/k.babayev/dissertation/internal/models"
)

const (
	validatorURL   = "http://validator:8081/validate"
	transactionURL = "http://transaction:8082/process"
)

func depositGatewayHandler(w http.ResponseWriter, r *http.Request) {
	var req models.DepositRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	deposit := req.ToEntity()
	payload, _ := json.Marshal(deposit)

	valResp, err := http.Post(validatorURL, "application/json", bytes.NewBuffer(payload))
	if err != nil || valResp.StatusCode != http.StatusOK {
		http.Error(w, "Validation failed", http.StatusInternalServerError)
		return
	}

	transResp, err := http.Post(transactionURL, "application/json", bytes.NewBuffer(payload))
	if err != nil || transResp.StatusCode != http.StatusOK {
		http.Error(w, "Transaction failed", http.StatusInternalServerError)
		return
	}

	deposit.Status = "COMPLETED"
	resp := deposit.ToResponse()

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}

func main() {
	http.HandleFunc("/deposit", depositGatewayHandler)
	log.Println("Gateway Service running on port 8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
