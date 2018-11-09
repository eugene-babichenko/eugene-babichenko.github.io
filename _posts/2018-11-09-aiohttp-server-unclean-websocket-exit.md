---
layout: post
title:  "Finishing aiohttp websocket handlers cleanly when a client closed a socket incorrectly"
date:   2018-11-09 13:00:00 +0300
categories: python aiohttp server websockets
---

You might have noticed that there may be some troubles when an aiohttp was not
closed by a client in a clean way. When you follow the aiohttp
[official guide](https://docs.aiohttp.org/en/stable/web_quickstart.html#websockets)
on websockets but errors are not processed in the right way. Here's a little
trick that might help you with that.

So let's recall the aiohttp example:

```python
async def websocket_handler(request):

    ws = web.WebSocketResponse()
    await ws.prepare(request)

    async for msg in ws:
        if msg.type == aiohttp.WSMsgType.TEXT:
            if msg.data == 'close':
                await ws.close()
            else:
                await ws.send_str(msg.data + '/answer')
        elif msg.type == aiohttp.WSMsgType.ERROR:
            print('ws connection closed with exception %s' %
                  ws.exception())

    print('websocket connection closed')

    return ws
```

Seems like nothing is wrong with that except you don’t receive an appropriate
error message and it looks like code after the loop is never executed if just
terminate a client app without properly closing the socket.

The tricky part here is that when your websocket was closed uncleanly you get
the `asyncio.CancelledError`. So all you need to perform the code after the loop
is to wrap the loop in a try-except statement:

```python
async def websocket_handler(request):

    ws = web.WebSocketResponse()
    await ws.prepare(request)

    try:
        async for msg in ws:
            if msg.type == aiohttp.WSMsgType.TEXT:
                if msg.data == 'close':
                    await ws.close()
                else:
                    await ws.send_str(msg.data + '/answer')
            elif msg.type == aiohttp.WSMsgType.ERROR:
                print('ws connection closed with exception %s' %
                      ws.exception())
    except asyncio.CancelledError:
        print('Unclean exit by the client')

    # Now this is always executed
    print('websocket connection closed')

    return ws
```
