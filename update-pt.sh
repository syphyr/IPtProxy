cd IPtProxy.go

go get gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird@latest
go get gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/v2@latest
go mod tidy
go get golang.org/x/mobile/bind
