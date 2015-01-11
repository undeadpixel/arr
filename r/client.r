# TODO: silently install packages if not installed!!!

library('jsonlite')

connectToServer = function(port) {
  while(TRUE) {
    socket = try(suppressWarnings(socketConnection('localhost', port, open="w+", blocking=TRUE)), TRUE)
    if(inherits(socket, 'try-error')) {
      Sys.sleep(0.1)
    } else {
      break
    }
  }
  return(socket)
}

listenToMessages = function() {
  while(TRUE) {
    message = readLines(SOCKET, n=1)
    # debug('received', message)
    message = try(fromJSON(message), TRUE)

    if(is.list(message)) {
      if(message$type == 'query') {
        processQuery(message$query)
      }
    }
  }
}

processQuery = function(query) {
  # test if it parses
  parsed_query = try(parse(text=query), TRUE)
  if(inherits(parsed_query, 'try-error')) {
    sendError("Parse error")
    return(FALSE)
  } else {
    # run code in an isolated scope
    new_environment = new.env()
    results = eval(parsed_query, env=new_environment)

    sendResults(results)

    return(TRUE)
  }
}

# send message functions

sendResults = function(results) {
  message = list(type = 'results', results = processResults(results))
  sendMessage(message)
}

sendError = function(error) {
  message = list(type = 'error', error = error)
  sendMessage(message)
}

sendMessage = function(message) {
  encoded_message = toJSON(message, auto_unbox=TRUE)
  writeLines(encoded_message, SOCKET)
  flush(SOCKET)
  # debug('sent', encoded_message)
}

# process results

processResults = function(results) {
  serializeJSON(results)
}

# nasty debug function (will be removed soon...)

debug = function(title, message) {
  message(paste0("!! ", toupper(title), ": ", message))
}

