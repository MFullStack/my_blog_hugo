---
title:       "Kubernetes WebSocket 实现 Pod Web Terminal"
subtitle:    "kubectl exec -it console-deployment-58bd64dd4b-szrwm -n caas-console /bin/sh"
description: ""
date:        2020-06-02
author:      "莫伟伟"
image:       "https://img.moweiwei.com/k8s-bg-gray.png"
tags:
    - kubernetes
    - Terminal
categories:  [ TECH ]
---

# Kubernetes WebSocket 实现 Pod Web Terminal

WebSocket是一种网络传输协议，可在单个TCP连接上进行全双工通信。WebSocket使得客户端和服务器之间的数据交换变得更加简单，允许服务端主动向客户端推送数据。在WebSocket API中，浏览器和服务器只需要完成一次握手，两者之间就可以创建持久性的连接，并进行双向数据传输。
WebSocket握手使用HTTP Upgrade头从HTTP协议更改为WebSocket协议。

## 1. kubernetes exec API

`kubernetes exec api` 作用类似于 `kubectl exec` 命令。通过 Websocket 连接后，可进入容器内执行 shell命令。
完整的 API 例子如下：

```sh
ws://172.20.148.78:30001/api/v1/namespaces/${namespace}/pods/${pod}/exec?container=${container}&stdout=1&stdin=1&stderr=1&tty=1&command=/bin/sh
```

上述 API 中参数的定义，参考如下 kubernetes Swagger 描述：

```json
    "/api/v1/namespaces/{namespace}/pods/{name}/exec": {
      "get": {
        "consumes": [
          "*/*"
        ],
        "description": "connect GET requests to exec of Pod",
        "operationId": "connectCoreV1GetNamespacedPodExec",
        "produces": [
          "*/*"
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "type": "string"
            }
          },
          "401": {
            "description": "Unauthorized"
          }
        },
        "schemes": [
          "https"
        ],
        "tags": [
          "core_v1"
        ],
        "x-kubernetes-action": "connect",
        "x-kubernetes-group-version-kind": {
          "group": "",
          "kind": "PodExecOptions",
          "version": "v1"
        }
      },
      "parameters": [
        {
          "description": "Command is the remote command to execute. argv array. Not executed within a shell.",
          "in": "query",
          "name": "command",
          "type": "string",
          "uniqueItems": true
        },
        {
          "description": "Container in which to execute the command. Defaults to only container if there is only one container in the pod.",
          "in": "query",
          "name": "container",
          "type": "string",
          "uniqueItems": true
        },
        {
          "description": "name of the PodExecOptions",
          "in": "path",
          "name": "name",
          "required": true,
          "type": "string",
          "uniqueItems": true
        },
        {
          "description": "object name and auth scope, such as for teams and projects",
          "in": "path",
          "name": "namespace",
          "required": true,
          "type": "string",
          "uniqueItems": true
        },
        {
          "description": "Redirect the standard error stream of the pod for this call. Defaults to true.",
          "in": "query",
          "name": "stderr",
          "type": "boolean",
          "uniqueItems": true
        },
        {
          "description": "Redirect the standard input stream of the pod for this call. Defaults to false.",
          "in": "query",
          "name": "stdin",
          "type": "boolean",
          "uniqueItems": true
        },
        {
          "description": "Redirect the standard output stream of the pod for this call. Defaults to true.",
          "in": "query",
          "name": "stdout",
          "type": "boolean",
          "uniqueItems": true
        },
        {
          "description": "TTY if true indicates that a tty will be allocated for the exec call. Defaults to false.",
          "in": "query",
          "name": "tty",
          "type": "boolean",
          "uniqueItems": true
        }
      ]
    },
```

## 2. 测试 Kubernetes Websocket API

使用 wscat 工具进行本地 Websocket 测试. 安装及使用参考 [wscat](https://github.com/websockets/wscat)。
测试示例参考如下：

```sh
wscat -c "ws://172.20.148.78:30001/api/v1/namespaces/ns-mo/pods/project1-6f5fc9bdfd-mh8t7/exec?container=container-64k6oa&stdin=1&stdout=1&stderr=1&tty=1&command=ls" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1OTA5OTczMTUsImlhdCI6MTU5MDk5MDExNSwibmJmIjoxNTkwOTkwMTE1LCJzdWIiOiJhZG1pbiJ9.Fe1h0Ef92abIE-sypsiXl96SXfd6PiNz08fHRC9tN4gtRBkIXUtCmjiR6vLWntcA4_SbxsS57D7ze59ES2_xIg"
```

## 3. Kubernetes Websocket subprotocol

Kubernetes WebSocket接口遵循WebSocket协议，并在此基础上设计了子协议。Websocket 在与 kubernetes 握手通信时，需要在 header 中定义子协议。否则 Websocket 握手时报如下错误：

```
Response must not include 'Sec-WebSocket-Protocol' header if not present in request
```

关于 Kubernetes Websocket 子协议，在 [kubernetes apiserver](https://github.com/kubernetes/apiserver/blob/master/pkg/util/wsstream/conn.go) 中有如下描述。

```go
// The Websocket subprotocol "channel.k8s.io" prepends each binary message with a byte indicating
// the channel number (zero indexed) the message was sent on. Messages in both directions should
// prefix their messages with this channel byte. When used for remote execution, the channel numbers
// are by convention defined to match the POSIX file-descriptors assigned to STDIN, STDOUT, and STDERR
// (0, 1, and 2). No other conversion is performed on the raw subprotocol - writes are sent as they
// are received by the server.
//
// Example client session:
//
//    CONNECT http://server.com with subprotocol "channel.k8s.io"
//    WRITE []byte{0, 102, 111, 111, 10} # send "foo\n" on channel 0 (STDIN)
//    READ  []byte{1, 10}                # receive "\n" on channel 1 (STDOUT)
//    CLOSE
//
const ChannelWebSocketProtocol = "channel.k8s.io"

// The Websocket subprotocol "base64.channel.k8s.io" base64 encodes each message with a character
// indicating the channel number (zero indexed) the message was sent on. Messages in both directions
// should prefix their messages with this channel char. When used for remote execution, the channel
// numbers are by convention defined to match the POSIX file-descriptors assigned to STDIN, STDOUT,
// and STDERR ('0', '1', and '2'). The data received on the server is base64 decoded (and must be
// be valid) and data written by the server to the client is base64 encoded.
//
// Example client session:
//
//    CONNECT http://server.com with subprotocol "base64.channel.k8s.io"
//    WRITE []byte{48, 90, 109, 57, 118, 67, 103, 111, 61} # send "foo\n" (base64: "Zm9vCgo=") on channel '0' (STDIN)
//    READ  []byte{49, 67, 103, 61, 61} # receive "\n" (base64: "Cg==") on channel '1' (STDOUT)
//    CLOSE
//
const Base64ChannelWebSocketProtocol = "base64.channel.k8s.io"
```

本文使用 `base64.channel.k8s.io` 子协议，协议实际上将作为header “Sec-WebSocket-Protocol : base64.channel.k8s.io“传输。前端具体代码如下。

## JavaScript 连接 Kubernetes Websocket 代码段

Terminal 部分代码：

```js
import { Terminal } from 'xterm'
import * as fit from 'xterm/lib/addons/fit/fit'

Terminal.applyAddon(fit)

const DEFAULT_TERMINAL_OPTS = {
  lineHeight: 1.2,
  cursorBlink: true,
  cursorStyle: 'underline',
  fontSize: 12,
  fontFamily: "Monaco, Menlo, Consolas, 'Courier New', monospace",
  theme: {
    background: '#181d28',
  },
}

...

initTerm() {
    const { initText } = this.props
    const terminalOpts = this.getTerminalOpts()
    const term = new Terminal(terminalOpts)
    term.open(this.containerRef.current)
    term.write(initText)
    term.fit()

    return term
  }
...

```

Websocket 实例：

```js
...
websocketUrl() {
    const { namespace, pod, container } = this.kubectl
    return `api/v1/namespaces/${namespace}/pods/${pod}/exec?container=${container}&stdout=1&stdin=1&stderr=1&tty=1&command=/bin/sh`
  }
...

createWS() {
    return new WebSocket(this.props.websocketUrl, 'base64.channel.k8s.io')
  }
...
```

Websocket send:

```js
sendTerminalInput = data => {
    if (this.isWsOpen) {
      this.ws.send(`0${btoa(data)}`)
    }
  }
```

Websocket received：

```js
onWSReceive = ev => {
    const data = ev.data.slice(1)
    const term = this.term

    if (this.first) {
      this.first = false
      this.disableTermStdin(false)
      term.reset()
      term.element && term.focus()
      this.resizeRemoteTerminal()
    }

    switch (ev.data[0]) {
      case '1':
      case '2':
      case '3': {
        const stdout = atob(data)
        term.write(stdout)
        break
      }
      default:
        break
    }
  }
```
