package client

// import (
// 	"context"
// 	"fmt"

// 	"github.com/valkey-io/valkey-go"
// )

// const (
// 	redisAddr = "localhost:6379"
// 	keyData   = "new-redis"
// 	valueData = "Valkey"
// )

// func main() {
// 	client, err := valkey.NewClient(valkey.ClientOption{
// 		InitAddress: []string{redisAddr},
// 	})
// 	if err != nil {
// 		panic(err)
// 	}
// 	defer client.Close()

// 	ctx := context.Background()
// 	err = client.Do(ctx, client.B().Set().Key(keyData).Value(valueData).Build()).Error()
// 	if err != nil {
// 		panic(err)
// 	}

// 	value, err := client.Do(ctx, client.B().Get().Key(keyData).Build()).ToString()
// 	if err != nil {
// 		panic(err)
// 	}
// 	fmt.Println(value)
// }
