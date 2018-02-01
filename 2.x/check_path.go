package main

import (
	"fmt"
	"os"
	"strings"
	"time"

	zk "github.com/samuel/go-zookeeper/zk"
)

func main() {
	zkAddress := strings.Split(os.Args[1], ",")
	path := os.Args[2]
	c, _, _ := zk.Connect(zkAddress, time.Second*10)
	exists, _, err := c.Exists(path)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	if exists == true {
		fmt.Println(path, "exist")
		os.Exit(1)
	}
	fmt.Println(path, "not exist")
	os.Exit(0)
}
