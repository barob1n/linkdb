
/**
 * @fileoverview Search developers.google.com/web for articles tagged
 * "Headless Chrome" and scrape results from the results page.
 */

 'use strict';

 const puppeteer = require('puppeteer');


 

 (async () => {

    function table_to_csv(anchors){


    }
    
   const browser = await puppeteer.launch({headless: true });
   const page = await browser.newPage();
  
   // tecq search page
   await page.goto('https://www2.tceq.texas.gov/airperm/index.cfm?fuseaction=airpermits.start',{waitUntil: 'load', timeout: 0});
  
   // inputs and options
   const counties_select = '#wrapper > table > tbody > tr > td > form > table > tbody > tr:nth-child(2) > td > table > tbody > tr > td > table > tbody > tr:nth-child(1) > td:nth-child(2) > select'
   const submit = '#wrapper > table > tbody > tr > td > form > table > tbody > tr:nth-child(4) > td > table > tbody > tr > td > table > tbody > tr:nth-child(2) > td > input[type=image]:nth-child(1)'
   const radio = '#wrapper > table > tbody > tr > td > form > table > tbody > tr:nth-child(4) > td > table > tbody > tr > td > table > tbody > tr:nth-child(1) > td:nth-child(1) > input[type=radio]:nth-child(2)'
   
   // get list of counties
   const counties_array = await page.evaluate((counties_select) =>{
        const select = Array.from(document.querySelectorAll(counties_select)[0])
        var options=[];
        for(i=1;i<select.length;i++){
            options.push(select[i].value)
        }
        return(options) 
   },counties_select)

   //iterate through counties counties
   for(var cnty_i=0;cnty_i<counties_array.length;cnty_i++){

        // select county
        await page.select(counties_select, counties_array[cnty_i])
        
        // select 'ALL' radio button
        page.waitForSelector(radio)
        await page.click(radio),
        
        // submit and wait for next page
        await Promise.all([
            page.waitForSelector(submit),
            page.click(submit),
            page.setDefaultNavigationTimeout(0),
            page.waitForNavigation()
        ]);

        // Extract the results from the page.
        const tableSelector = 'table';
        await page.waitForSelector(tableSelector);
        const links = await page.evaluate((tableSelector) => {
            const anchors = Array.from(document.querySelectorAll(tableSelector));
            var tbl= anchors.map((anchor) => {
                var separator = ',';
                var rows = anchor.querySelectorAll('tr');
                console.log(JSON.stringify(anchor))
                // Construct csv
                var csv = [];
                for (var i = 0; i < rows.length; i++) {
                    var row = [], cols = rows[i].querySelectorAll('td, th');
                    for (var j = 0; j < cols.length; j++) {
                        // Clean innertext to remove multiple spaces and jumpline (break csv)
                        var data = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, '').replace(/(\s\s)/gm, ' ')
                        // Escape double-quote with double-double-quote (see https://stackoverflow.com/questions/17808511/properly-escape-a-double-quote-in-csv)
                        data = data.replace(/"/g, '""');
                        // Push escaped string
                        row.push('"' + data + '"');
                    }
                    csv.push(row.join(separator));
                }
                var csv_string = csv.join('\n');
                return(csv_string)
            })
        
            return tbl;
               
        }, tableSelector);

        // write table
        console.log(links.join('\n'));

        console.log('********************' + counties_array[cnty_i] + '*******************,\n')
        
        await page.waitForTimeout(5000)

        // return to tecq search page
        await Promise.all([
            page.goto('https://www2.tceq.texas.gov/airperm/index.cfm?fuseaction=airpermits.start',{waitUntil: 'load', timeout: 0}),
            page.waitForNavigation()
        ]);
   }

   
   await browser.close();
 })();