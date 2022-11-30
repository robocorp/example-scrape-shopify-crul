# Scrape price data from a Shopify shop

We found this new really cool tool [Crul](https://www.crul.com/), and wanted to put it in use! While it can handle data from APIs as well, in this case we are scraping product name and price data from a e-commerce site that runs on [Shopify](https://www.shopify.com/), and store it to an Excel file with a timestamp.

> This might not work out of the box with ANY Shopify store, but go ahead and try. It's easy to edit the query.
## What you will learn with this example

- How to invoke Crul queries from a robot
- How to extend Robot Framework robot with Python class
- How to write data to a locally stored Excel

## Prerequisites

- Get a hosted account and credentials from [Crul](https://www.crul.com/). Try your luck in their [Slack](https://crulinc.slack.com/).
- Set up a Vault in your [Robocorp Control Room](https://cloud.robocorp.com) with name `Crul` and have one key called `apikey` that has your Crul API key in this format: `crul [KEYHERE-IT-IS-LONG]`.

## Crul query explained

Hoping to get Nic and Carl to help here! :)

```
open https://www.tentree.ca/collections/mens-shorts --html --hashtml
|| filter "(attributes.class == 'justify-between product-attr-container mt-2 relative')"
|| sequence
|| html innerHTML
|| filter "(_html.nodeName == 'A') or (_html.attributes.class == 'text-discount-price')"
|| table _html.innerText outerHTMLHash _sequence
|| groupBy outerHTMLHash
|| rename group.0._html.innerText product
|| rename group.1._html.innerText price
|| sort group.0._sequence
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
