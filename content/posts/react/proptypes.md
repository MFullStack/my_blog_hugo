---
title: "Proptypes"
date: 2019-09-12T14:02:57+08:00
hidden: false
draft: false
tags: [react, proptypes]
keywords: []
categories: []
description: ""
---

# 有状态组件与无状态组件 props 类型检查

## 有状态组件

```javascript
import React, { PureComponent } from "react";
import PropTypes from "prop-types";

export default class Comment extends PureComponent {
  static propTypes = {
    comment: PropTypes.object.isRequired
  };
  static defaultProps = {
    comment: []
  }

  render() {
    const { author, content } = this.props.comment;
    return (
      <div className="comment-item">
        <span className="avatar" />
        <a href="#">{author}</a>
        <p>{content}</p>
      </div>
    );
  }
}
```

## 无状态组件

```javascript
import React from "react";
import PropTypes from "prop-types";
import CommentItem from "./CommentItem";

const CommentList = props => {
  return (
    <div className="comment-list">
      {props.comments.map(comment => (
        <CommentItem comment={comment} />
      ))}
    </div>
  );
};

CommentList.protoTypes = {
  comments: PropTypes.object.isRequired
};
CommentList.defaultProps = {
  comment: []
}
export default CommentList;
```
