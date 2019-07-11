<#--
Header section of the GetFeatureInfo HTML output. Should have the <head> section, and
a starter of the <body>. It is advised that eventual css uses a special class for featureInfo,
since the generated HTML may blend with another page changing its aspect when usign generic classes
like td, tr, and so on.
-->
<html>
  <head>
    <title>GeoServer GetFeatureInfo output</title>
  </head>
  <style type="text/css">
        @import url('https://fonts.googleapis.com/css?family=IBM+Plex+Sans+Condensed:300,400,500,700&display=swap');
        body {
                padding:1em;
        }
        table.featureInfo, table.featureInfo td, table.featureInfo th {
                font-family: 'IBM Plex Sans Condensed', 'Barlow Semi Condensed', Zurich, Univers, Helvetica, Arial, sans-serif, sans;
                border:0px solid #ddd;
                border-collapse:collapse;
                margin-left: auto;
                margin-right: auto;
                padding:0;
                width: 700px;
                font-size: 100%;
                font-weight: 400;
                font-size: 13px;
                /*padding:.2em .1em;*/
        }
        table.featureInfo a:link  {
                color: #4C8FBA;
                text-decoration: none;                
        }
        table.featureInfo a:visited {
                color: #4C8FBA;
                text-decoration: none;
        }
        table.featureInfo a:hover {
                color: #4C8FBA;
                text-decoration: none;
        }
        table.featureInfo a:active {
                color: #4C8FBA;
                text-decoration: none;
        }
        table.featureInfo th{
                padding:.2em .2em;
                /*text-transform:uppercase;*/
                font-weight:400;
                background:#eee;
        }
        table.featureInfo td{
                background:#fff;
                padding: 0.3em;
                vertical-align: top;
        }
        table.featureInfo tr.odd td{
                background:#eee;
        }
        table.featureInfo caption{
                text-align:left;
                font-size:120%;
                font-weight:700;
                /*text-transform:uppercase;*/
                padding:.2em .2em;
        }
        table.documents, table.documents td, table.documents tr {
                padding:.1em;
                border:0px solid #ddd;
                vertical-align:top;
        }
        hr {
                display: block;
                height: 1px;
                border: 0;
                border-top: 1px solid #ccc;
                margin: 1em 0;
                padding: 0;
        }
  </style>
  <body>
