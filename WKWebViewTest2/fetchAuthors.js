var authors = document.querySelectorAll('.c-content-author')
function parseAuthors() {
    result = []
    for (var i = 0; i < authors.length; i++) {
        var author = authors[i]
        var authorItem = author.querySelector('.c-content-author__title')
//        var authorURL = "http://www.raywenderlich.com" + authorItem.querySelector('a').getAttribute('href');
        var authorName = authorItem.querySelector('a').textContent;
        result.push({'authorName' : authorName});
    }
    return result
}

var authors = parseAuthors();
webkit.messageHandlers.didFetchAuthors.postMessage(authors)
