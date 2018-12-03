let msgPush = ({
    pushContent,
    payload
}) => {
    plus.push.createMessage(pushContent, payload, {
        cover: false
    })
}

export {
    msgPush
}
