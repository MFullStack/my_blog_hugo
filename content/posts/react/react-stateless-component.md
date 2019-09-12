---
title: "React Stateless Component"
date: 2019-09-12T10:47:29+08:00
hidden: false
draft: false
tags: [react, 无状态组件]
keywords: []
categories: []
description: ""
---

# 无状态组件

## 无状态组件的三种写法

```javascript
import React from "react";

// 方式 1
const MesssageList = props => {
  return (
    <ul>
      {props.messages.map(msg => (
        <li>{msg}</li>
      ))}
    </ul>
  );
};

// 方式 2
function MesssageList(props){
  return (
    <ul>
      {props.messages.map(msg => (
        <li>{msg}</li>
      ))}
    </ul>
  );
};

// 方式 3
class MesssageList extends React.PureComponent {
  render() {
    return (
      <ul>
        {this.props.messages.map(msg => (
          <li>{msg}</li>
        ))}
      </ul>
    );
  }
}

export class ChatApp extends React.Component {
  state = {
    messages: [],
    inputmsg: ""
  };

  handleInput = e => {
    this.setState({
      inputmsg: e.target.value
    });
  };

  handleSend = () => {
    const content = this.state.inputmsg;
    if (content) {
      const newMessage = [...this.state.messages, content];
      this.setState({
        messages: newMessage,
        inputmsg: ""
      });
    }
  };

  render() {
    return (
      <div>
        <MesssageList messages={this.state.messages} />
        <div>
          <input value={this.state.inputmsg} onChange={this.handleInput} />
          <button onClick={this.handleSend}>Send</button>
        </div>
      </div>
    );
  }
}

export default ChatApp;

```
