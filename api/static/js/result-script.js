function syntaxHighlight(json) {
    if (typeof json !== 'string') {
        json = JSON.stringify(json, null, 2);
    }

    json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

    json = json.replace(/(\[)(\s*?)([^\[\]]*?)(\s*?)(\])/g, function(match, p1, p2, p3, p4, p5) {
        return p1 + p3.replace(/\s+/g, ' ') + p5;
    });

    return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|\b\d+(\.\d+)?([eE][+-]?\d+)?)/g, function(match) {
        let cls = 'json-number';
        if (/^"/.test(match)) {
            cls = /:$/.test(match) ? 'json-key' : 'json-string';
        } else if (/true|false/.test(match)) {
            cls = 'json-boolean';
        } else if (/null/.test(match)) {
            cls = 'json-null';
        }
        return '<span class="' + cls + '">' + match + '</span>';
    });
}

document.querySelector('form').addEventListener('submit', async function(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const response = await fetch(event.target.action, {
        method: 'POST',
        body: formData
    });
    const result = await response.json();

    const resultElement = document.getElementById('result');
    const jsonContentElement = document.getElementById('json-content');

    if (Object.keys(result).length > 0) {
        jsonContentElement.innerHTML = syntaxHighlight(result);
        resultElement.style.display = 'block';
    } else {
        resultElement.style.display = 'none';
    }
});
