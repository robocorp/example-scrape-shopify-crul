# Scrape price data from a Shopify shop

We found this new really cool tool [Crul](https://www.crul.com/), and wanted to put it in use! While it can handle data from APIs as well, in this case we are scraping product name and price data from a e-commerce site that runs on [Shopify](https://www.shopify.com/), and store it to an Excel file with a timestamp.

> This might not work out of the box with ANY Shopify store, but go ahead and try. It's easy to edit the query.

## Prerequisites

- Get a hosted account and credentials from [Crul](https://www.crul.com/). Try your luck in their [Slack](https://crulinc.slack.com/).
- Set up a Vault in your Robocorp Control Room with name `Crul`and have one key called `apikey` that has your Crul API key in this format: `crul [KEYHERE-IT-IS-LONG]`.

## Crul query explained

To get a better idea of how a Crul query works in general, check out the [documentation](https://www.crul.com/docs/introduction) and [quickstart](https://www.crul.com/quickstart)!

Below is query that included as an example in the `crul-query.txt` file of this robot. This query has been broken up by stage and documented. It's a verbose explanation as this could be your first time seeing a Crul query, but reach out to [us](https://crulinc.slack.com/) any time and we would love to answer any questions or help you write your own queries!

1.) Opens the provided URL, renders the page, and transforms into a tabular structure which includes the html, and hashes of the html for future grouping.
```
open https://www.tentree.ca/collections/mens-shorts --html --hashtml
```
2.) Filters the page data to only include elements matching the filter expression.
```
|| filter "(attributes.class == 'justify-between product-attr-container mt-2 relative')"
```
3.) Adds a _sequence column to each row containing the row number.
```
|| sequence
```
4.) Processes the element HTML into a row for each of its children.
```
|| html innerHTML
```
5.) Filters the page data to only include elements matching the filter expression.
```
|| filter "(_html.nodeName == 'A') or (_html.attributes.class == 'text-discount-price')"
```
6.) Include only relevant columns.
```
|| table _html.innerText outerHTMLHash _sequence
```
7.) Groups page elements by the parent hash.
```
|| groupBy outerHTMLHash
```
8.) Renames a column.
```
|| rename group.0._html.innerText product
```
9.) Renames a column.
```
|| rename group.1._html.innerText price
```
10.) Sorts according to the previously added sequence number to preserve the order of elements as they appear on the page.
```
|| sort group.0._sequence
```
11.) Adds a timestamp to each row.
```
|| addcolumn time $TIMESTAMP.ISO$
```
12.) Include only relevant in the final set of results.
```
|| table product price time
```

## Robot explained

Robot itself is straightforward, and showcases how to use [Python](CrulWrapper.py) to extend the capabilities. Crul communications is wrapped in a multipurpose class that can be reused with other robots. With that's there is two key pieces.

This part gets a query string from a text file, calls the Crul wrapper and creates a table from the results.

```
${query}=      Get File    ${query_file}
${results}=    Run Query    ${query}
${table}=      Create Table    ${results}
```

This for-loop iterates through data and appends the rows to an Excel.

```
FOR    ${row}    IN    @{data}
    Append Rows To Worksheet    ${row}  header=${TRUE}
END
```

## Running it

You can edit the Crul query in the [crul-query.txt](crul-query.txt) file, but apart from that running is straightforward. Do it in your dev tools, or set up a Process in the Control Room.
