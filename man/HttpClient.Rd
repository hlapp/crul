% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/client.R
\docType{data}
\name{HttpClient}
\alias{HttpClient}
\title{HTTP client}
\arguments{
\item{url}{(character) A url. One of \code{url} or \code{handle} required.}

\item{opts}{(list) curl options, a named list. See
\code{\link[curl]{curl_options}} for available curl options}

\item{proxies}{an object of class \code{proxy}, as returned from the
\code{\link{proxy}} function. Supports one proxy for now}

\item{auth}{result of a call to the \code{\link{auth}} function,
e.g. \code{auth(user = "foo", pwd = "bar")}}

\item{headers}{(list) a named list of headers}

\item{handle}{A handle, see \code{\link{handle}}}

\item{progress}{a function with logic for printing a progress
bar for an HTTP request, ultimiately passed down to \pkg{curl}.
only supports httr::progress() for now}
}
\description{
HTTP client
}
\details{
\strong{Methods}
\describe{
\item{\code{get(path, query, disk, stream, ...)}}{
Make a GET request
}
\item{\code{post(path, query, body, disk, stream, ...)}}{
Make a POST request
}
\item{\code{put(path, query, body, disk, stream, ...)}}{
Make a PUT request
}
\item{\code{patch(path, query, body, disk, stream, ...)}}{
Make a PATCH request
}
\item{\code{delete(path, query, body, disk, stream, ...)}}{
Make a DELETE request
}
\item{\code{head(path, query, ...)}}{
Make a HEAD request
}
\item{\code{retry(verb, ..., pause_base = 1, pause_cap = 60, pause_min = 1, times = 3, terminate_on, retry_only_on, onwait)}}{
Retries the request given by \code{verb} until successful (HTTP response
status < 400), or a condition for giving up is met. Automatically
recognizes \code{Retry-After} and \code{X-RateLimit-Reset} headers in the
response for rate-limited remote APIs.
}
\item{\code{handle_pop()}}{
reset your curl handle
}
\item{\code{url_fetch(path, query)}}{
get the URL that would be sent (i.e., before executing the request).
the only things that change the URL are path and query
parameters; body and any curl options don't change the URL
- returns: URL as a character vector
}
}

Possible parameters (not all are allowed in each HTTP verb):
\itemize{
\item \code{path} - URL path, appended to the base URL
\item \code{query} - query terms, as a named list
\item \code{body} - body as an R list
\item \code{encode} - one of form, multipart, json, or raw
\item \code{disk} - a path to write to. if NULL (default), memory used.
See \code{\link[curl:curl_fetch_disk]{curl::curl_fetch_disk()}} for help.
\item \code{stream} - an R function to determine how to stream data. if
NULL (default), memory used. See \code{\link[curl:curl_fetch_stream]{curl::curl_fetch_stream()}}
for help
\item \code{...} For \code{retry}, the options to be passed on to the method
implementing the requested verb, including curl options. Otherwise,
curl options, only those in the acceptable set from \code{\link[curl:curl_options]{curl::curl_options()}}
except the following: httpget, httppost, post, postfields, postfieldsize,
and customrequest
\item \code{pause_base,pause_cap,pause_min} - basis, maximum, and minimum for
calculating wait time for retry. Wait time is calculated according to the
exponential backoff with full jitter algorithm. Specifically, wait time is
chosen randomly between \code{pause_min} and the lesser of \code{pause_base * 2} and
\code{pause_cap}, with \code{pause_base} doubling on each subsequent retry attempt.
Use \code{pause_cap = Inf} to not terminate retrying due to cap of wait time
reached.
\item \code{times} - the maximum number of times to retry. Set to \code{Inf} to
not stop retrying due to exhausting the number of attempts.
\item \code{terminate_on,retry_only_on} - a vector of HTTP status codes. For
\code{terminate_on}, the status codes for which to terminate retrying, and for
\code{retry_only_on}, the status codes for which to retry the request.
\item \code{onwait} - a callback function if the request will be retried and
a wait time is being applied. The function will be passed two parameters,
the response object from the failed request, and the wait time in seconds.
Note that the time spent in the function effectively adds to the wait time,
so it should be kept simple.
}
}
\note{
A little quirk about \code{crul} is that because user agent string can
be passed as either a header or a curl option (both lead to a \code{User-Agent}
header being passed in the HTTP request), we return the user agent
string in the \code{request_headers} list of the response even if you
pass in a \code{useragent} string as a curl option. Note that whether you pass
in as a header like \code{User-Agent} or as a curl option like \code{useragent},
it is returned as \code{request_headers$User-Agent} so at least accessing
it in the request headers is consistent.
}
\section{handles}{

curl handles are re-used on the level of the connection object, that is,
each \code{HttpClient} object is separate from one another so as to better
separate connections.

If you don't pass in a curl handle to the \code{handle} parameter,
it gets created when a HTTP verb is called. Thus, if you try to get \code{handle}
after creating a \code{HttpClient} object only passing \code{url} parameter, \code{handle}
will be \code{NULL}. If you pass a curl handle to the \code{handle parameter, then  you can get the handle from the }HttpClient\code{object. The response from a  http verb request does have the handle in the}handle` slot.
}

\examples{
\dontrun{
# set your own handle 
(h <- handle("https://httpbin.org"))
(x <- HttpClient$new(handle = h))
x$handle
x$url
(out <- x$get("get"))
x$handle
x$url
class(out)
out$handle

# if you just pass a url, we create a handle for you
#  this is how most people will use HttpClient
(x <- HttpClient$new(url = "https://httpbin.org"))
x$url
x$handle # is empty, it gets created when a HTTP verb is called
(r1 <- x$get('get'))
x$url
x$handle 
r1$url
r1$handle
r1$content
r1$response_headers
r1$parse()

(res_get2 <- x$get('get', query = list(hello = "world")))
res_get2$parse()
library("jsonlite")
jsonlite::fromJSON(res_get2$parse())

# post request
(res_post <- x$post('post', body = list(hello = "world")))

## empty body request
x$post('post')

# put request
(res_put <- x$put('put'))

# delete request
(res_delete <- x$delete('delete'))

# patch request
(res_patch <- x$patch('patch'))

# head request
(res_head <- x$head())

# retry, by default at most 3 times
(res_get <- x$retry("GET", path = "status/400"))

# retry, but not for 404 NOT FOUND
(res_get <- x$retry("GET", path = "status/404", terminate_on = c(404)))

# retry, but only for exceeding rate limit (note that e.g. Github uses 403)
(res_get <- x$retry("GET", path = "status/429", retry_only_on = c(403, 429)))

# query params are URL encoded for you, so DO NOT do it yourself
## if you url encode yourself, it gets double encoded, and that's bad
(x <- HttpClient$new(url = "https://httpbin.org"))
res <- x$get("get", query = list(a = 'hello world'))

# get full url before the request is made
(x <- HttpClient$new(url = "https://httpbin.org"))
x$url_fetch()
x$url_fetch('get')
x$url_fetch('post')
x$url_fetch('get', query = list(foo = "bar"))
}
}
\seealso{
\link{post-requests}, \link{delete-requests}, \link{http-headers},
\link{writing-options}, \link{cookies}
}
\keyword{datasets}
