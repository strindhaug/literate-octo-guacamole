# A small library of util functions I've created over the years just for convenience.

# create a "namespace" to store global variables, not to clutter the global scope.
# My name is pretty unique so that should probably never have accidental name collisions.
window.strindhaug ?= {}

# CONSTS

window.strindhaug.KEYUP_DELAY = 400


# Polyfills:
unless console?.log
    window.console = {
        log: ->
            return
        warn: ->
            return
        info: ->
            return
        error: ->
            return
    }

unless _?.debounce
    window._ = {
        debounce: (fun, time) ->
            return fun
    }

# from:https://github.com/jserz/js_piece/blob/master/DOM/ChildNode/remove()/remove().md

for item in [Element.prototype, CharacterData.prototype, DocumentType.prototype]
    do (item) ->
        if item.hasOwnProperty('remove')
            return
        Object.defineProperty(item, 'remove', {
            configurable: true,
            enumerable: true,
            writable: true,
            value: ->
                @?.parentNode?.removeChild(@)
        })


if window?.matchMedia?
    window.strindhaug.gt_medium = window.matchMedia("(min-width: 800px)")
else
    # fallback for ancient browsers from before 2011:
    window.strindhaug.gt_medium = {
        matches: true
    }

# ------------

elByTag = (tagname) ->
    return document.getElementsByTagName(tagname)

elById = (id) ->
    return document.getElementById(id)

elByClass = (classname) ->
    return document.getElementsByClassName(classname)

elByQuery = (query) ->
    return document.querySelector(query)


observe = (object, type, callback) ->
    if (object == null || typeof(object) == 'undefined')
        return

    if (object.addEventListener)
        object.addEventListener(type, callback, false)

    else if (object.attachEvent)
        object.attachEvent("on" + type, callback)
    else
        object["on" + type] = callback

observeMulti = (objects, type, callback) ->
    for o in objects
        observe(o, type, callback)

newEl = (type = "div", className, contentHtml) ->
    el = document.createElement(type)
    if className
        el.className = className
    if contentHtml
        el.innerHTML = contentHtml
    el

window.strindhaug.onresizeTasks = []
windowResized = _.debounce(->
    for task in window.strindhaug.onresizeTasks
        task()
    undefined
, 300)

#  Ajax

serialize = (obj) ->
    str = []
    for own key, val of obj
        str.push(encodeURIComponent(key) + "=" + encodeURIComponent(val))

    str.join("&")

doAjax = (url, callback, errcallback = null, data = null, method = "GET", multipart = false, headers = {}) ->
    xhr = new XMLHttpRequest()
    xhr.open(method, url)

    for key,value of headers
        xhr.setRequestHeader(key, value)

    if (multipart)
        xhr.setRequestHeader('Accept', 'application/json')
        xhr.send(data)
    else
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        xhr.send(serialize(data))

    xhr.onreadystatechange = ->
        DONE = 4 # readyState 4 means the request is done.
        OK = [200, 201, 202, 203, 204] # status in 200-range is a successful return.
        if (xhr.readyState is DONE)
            if (xhr.status in OK)
                if callback
                    callback(xhr.responseText)
            else
                if errcallback
                    errcallback(xhr.status)
                console.error('Error: ' + xhr.status)

    undefined

setCookie = (name, value, days) ->
    if days
        date = new Date()
        date.setTime( date.getTime() + (days * 24 * 60 * 60 * 1000) )
        expires = "; expires=" + date.toGMTString()
    else
        expires = ""

    document.cookie = name + "=" + value + expires + "; path=/"

getCookie = (name) ->
    nameEQ = name + "="
    ca = document.cookie.split(";")
    i = 0

    while i < ca.length
        c = ca[i]
        c = c.substring(1, c.length)  while c.charAt(0) is " "
        return c.substring(nameEQ.length, c.length)  if c.indexOf(nameEQ) is 0
        i++
    null

deleteCookie = (name) ->
    setCookie(name, "", -1)



#
window.strindhaug.elByTag = elByTag
window.strindhaug.elById = elById
window.strindhaug.elByClass = elByClass
window.strindhaug.elByQuery = elByQuery
window.strindhaug.observe = observe
window.strindhaug.observeMulti = observeMulti
window.strindhaug.newEl = newEl
window.strindhaug.doAjax = doAjax
window.strindhaug.setCookie = setCookie
window.strindhaug.getCookie = getCookie
window.strindhaug.deleteCookie = deleteCookie



observe(document, "DOMContentLoaded", (event) ->
    console.info("INIT")

    window.onresize = windowResized
    window.setTimeout(windowResized, 500)
    windowResized()

)
