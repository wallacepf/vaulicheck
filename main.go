package main

import "github.com/gin-gonic/gin"

var router *gin.Engine

func main() {

	router = gin.Default()
	router.LoadHTMLGlob("templates/*")

	initializeRoutes()

	router.Run("0.0.0.0:8080")
}
