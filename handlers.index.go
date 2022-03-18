package main

import (
	"encoding/json"
	"github.com/gin-gonic/gin"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"
)

type Response struct {
	Initialized                bool   `json:"initialized"`
	Sealed                     bool   `json:"sealed"`
	Standby                    bool   `json:"standby"`
	PerformanceStandby         bool   `json:"performance_standby"`
	ReplicationPerformanceMode string `json:"replication_performance_mode"`
	ReplicationDrMode          string `json:"replication_dr_mode"`
	ServerTimeUtc              int    `json:"server_time_utc"`
	Version                    string `json:"version"`
	ClusterName                string `json:"cluster_name"`
	ClusterID                  string `json:"cluster_id"`
	SecretPath                 string
	Secret                     string
}

var res Response

var (
	va = os.Getenv("VAULT_ADDR")
	sf = os.Getenv("SECRET_FILE")
	sp = os.Getenv("SECRET_PATH")
	ms = os.Getenv("MY_SECRET")
)

func vaultSecretCheck() string {
	data, err := ioutil.ReadFile(sf)
	if err != nil {
		log.Fatal(err)
	}

	return string(data)
}

func vaultHealthCheck() {
	resp, err := http.Get(os.Getenv("VAULT_ADDR") + "/v1/sys/health")
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err := json.Unmarshal(body, &res); err != nil {
		log.Fatal(err)
	}
}

func showIndexPage(c *gin.Context) {
	vaultHealthCheck()

	timestamp := int64(res.ServerTimeUtc)
	date := time.Unix(timestamp, 0)

	if sf != "" {
		ms = vaultSecretCheck()
	}

	c.HTML(http.StatusOK, "index.tmpl", gin.H{
		"title":         "Vault Check",
		"initialized":   res.Initialized,
		"sealed":        res.Sealed,
		"standby":       res.Standby,
		"version":       res.Version,
		"clusterName":   res.ClusterName,
		"serverTimeUtc": date,
		"secret":        ms,
		"secretPath":    sp,
	})
}
