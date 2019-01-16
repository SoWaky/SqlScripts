--This is a quick run through to generate the INSERT statements for all of the data in your table, using no scripts or add-ins to SQL Management Studio 2008 and above:
NOTE: this only works with Save to File, not Copy to Clipboard.

Right-click on the database and go to Tasks > Generate Scripts.
Select the tables (or objects) that you want to generate the script against.
Go to Set scripting options tab and click on the Advanced button.
In the General category, go to Type of data to script
There are 3 options: Schema Only, DATA ONLY, and Schema and Data. Select the appropriate option and click on OK.