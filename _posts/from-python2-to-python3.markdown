

Talk about this kind of fun :-)

```
    if isinstance(image, str):
        #Yaay Python fun, b64encode needs a bytes array
        image = bytes(image, "utf-8")

    #OMG, PYTHON IS REALLY FUN:
    #http://stackoverflow.com/questions/24369666/typeerror-b1-is-not-json-serializable
    #Now I have to convert it back to strings :-)
    #How you can fuck up that bad after 10 years of experience to improve the language ?
    #Why in the FUCKING HELL does b64encode returns a byte array ?
    #This is base64, it is ALWAYS AN ASCII STRING, are these guys retarded ? =/
    encodedImage = base64.b64encode(image).decode("utf-8")
    content = json.dumps({"image": encodedImage})
    return requests.post(
        captchanet_url,
        headers=headers,
        data=content
    )
```

It is optimized to be symmetric with base64 decode, but on this case it makes no
sense, at least for me, base64 are always strings, not generic raw byte sequences.
