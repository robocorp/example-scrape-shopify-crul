# Scrape price data from a Shopify shop

We found this new really cool tool [Crul](https://www.crul.com/), and wanted to put it in use! While it can handle data from APIs as well, in this case we are scraping product name and price data from a e-commerce site that runs on [Shopify](https://www.shopify.com/), and store it to an Excel file with a timestamp.

> This won't work out of the box with ANY Shopify store, but go ahead and try. It's easy to edit the query. The main differences between Shopify stores will be in the filter stages which specify the product listings.

## What you will learn with this example

- How to invoke Crul queries from a robot
- How to extend Robot Framework robot with Python class
- How to write data to a locally stored Excel

## Prerequisites

- Get a hosted account and credentials from [Crul](https://www.crul.com/). Try your luck in their [Slack](https://crulinc.slack.com/).
- Set up a Vault in your [Robocorp Control Room](https://cloud.robocorp.com) with name `Crul` and have one key called `apikey` that has your Crul API key in this format: `crul [KEY-HERE-IT-IS-LONG]`.

## Crul query explained

To get a better idea of how a Crul query works in general, check out the [documentation](https://www.crul.com/docs/introduction) and [quickstart](https://www.crul.com/quickstart)!

Below is query that included as an example in the `crul-query.txt` file of this robot. This query has been broken up by stage and documented. It's a verbose explanation as this could be your first time seeing a Crul query, but reach out to [Crul](https://crulinc.slack.com/) any time and we would love to answer any questions or help you write your own queries!

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
6.) This stage excludes any row containing the value “line-through” in the _html.innerHTML. The data set contains both the regular price and the sale price, so this stage will remove the regular price entry.
```
|| excludes _html.innerHTML "line-through"
```
7.) Include only relevant columns.
```
|| table _html.innerText outerHTMLHash _sequence
```
8.) This stage groups page elements by the parent hash calculated per element in the first stage of this query.
```
|| groupBy outerHTMLHash
```
9.) Renames a column.
```
|| rename _group.0._html.innerText product
```
10.) Renames a column.
```
|| rename _group.1._html.innerText price
```
11.) Sorts according to the previously added sequence number to preserve the order of elements as they appear on the page.
```
|| sort _group.0._sequence --order "ascending"
```
12.) Adds a timestamp column with the current ISO timestamp to each row.
```
|| addcolumn time $TIMESTAMP.ISO$
```
13.) Include only relevant columns in the final set of results.
```
|| table product price time
```

Here is the full Crul query.

```
open https://www.tentree.ca/collections/mens-shorts --html --hashtml
|| filter "(attributes.class == 'justify-between product-attr-container mt-2 relative')"
|| sequence
|| html innerHTML
|| filter "(_html.nodeName == 'A') or (_html.attributes.class == 'flex' or _html.attributes.class == 'text-discount-price')"
|| excludes _html.innerHTML "line-through"
|| table _html.innerText outerHTMLHash _sequence
|| groupBy outerHTMLHash
|| rename _group.0._html.innerText product
|| rename _group.1._html.innerText price
|| sort _group.0._sequence --order "ascending"
|| addcolumn time $TIMESTAMP.ISO$
|| table product price time
```

## Robot explained

Robot itself is straightforward, and showcases how to use [Python](CrulWrapper.py) to extend the capabilities. Crul communications is wrapped in a multipurpose class that can be reused with other robots. With that's there is two key pieces.

This part gets a query string from a text file, calls the Crul wrapper and creates a table from the results.

```
${query}=      Get File        ${query_file}
${results}=    Run Query       ${query}
${table}=      Create Table    ${results}
```

This for-loop iterates through data and appends the rows to an Excel.

```
FOR    ${row}    IN    @{data}
    Append Rows To Worksheet    ${row}    header=${TRUE}
END
```

## Running it

You can edit the Crul query in the [crul-query.txt](crul-query.txt) file, but apart from that running is straightforward. Do it in your VS Code by hitting the magic command and choose "Run Robot" (make sure to have our [extensions](https://robocorp.com/download) installed), or you can set up a Process in the Control Room and run it there.
