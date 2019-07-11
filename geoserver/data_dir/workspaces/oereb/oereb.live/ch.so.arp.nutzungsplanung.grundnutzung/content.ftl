<table class="featureInfo">
  <caption class="featureInfo">Nutzungsplanung - Grundnutzung</caption>
	<col style="width:30%">
	<col style="width:70%">
  <#list features as feature>
    <#assign attrs = feature.attributes >
    <tr>
      <td>Aussage:</td>
      <td>${attrs.aussage_de.value}</td>
    </tr>
    <tr>
      <td>Artcode:</td>
      <td>${attrs.artcode.value}</td>
    </tr>
    <tr>
      <td>Rechtsstatus:</td>
      <td>${attrs.rechtsstatus.value}</td>
    </tr>
    <tr>
      <td>Publiziert ab:</td>
      <td>${attrs.publiziertab.value?date('MM/dd/yy')?string["dd. MMMM yyyy"]}</td>
    </tr>
    <tr>
      <td colspan="2">Dokumente:</td>
    </tr>
        <#if "${attrs.dokumente.value}" != "">
          <#assign documents = "${attrs.dokumente.value}"?eval>
          <#list documents?sort_by("t_type")?reverse as document>
              <tr>
                <td style="font-weight:400;padding-left:2em;padding-top:0em;">Titel:</td>
                <td style="padding-top:0em;">${document.titel}</td>
              </tr>
              <tr>
                <td style="font-weight:400;padding-left:2em;padding-top:0em;">Offizieller Titel:</td>
                <td style="padding-top:0em;">${(document.offiziellertitel)!"&mdash;"}</td>
              </tr>
              <tr>
                <td style="font-weight:400;padding-left:2em;padding-top:0em;">Abkürzung:</td>
                <td style="padding-top:0em;">${document.abkuerzung}</td>
              </tr>
              <tr>
                <td style="font-weight:400;padding-left:2em;padding-top:0em;">Nummer:</td>
                <td style="padding-top:0em;">${document.offiziellenr}</td>
              </tr>
              <tr>
                <td style="font-weight:400;padding-left:2em;padding-top:0em;">Rechtsstatus:</td>
                <td style="padding-top:0em;">${document.rechtsstatus}</td>
              </tr>
              <tr>
                <td style="font-weight:400;padding-left:2em;padding-top:0em;">Publiziert ab:</td>
                <td style="padding-top:0em;">${document.publiziertab?date('yyyy-MM-dd')?string["dd. MMMM yyyy"]}</td>
              </tr>
              <tr>
                <td style="font-weight:400;padding-left:2em;padding-top:0em;">Link:</td>
                <td style="padding-top:0em;"><a href="${document.textimweb}" target="_blank">${document.textimweb}</a></td>
              </tr>
              <tr>
                <td>&nbsp;</td>
                <td></td>
              </tr>
          </#list>
        <#else>
          &nbsp;
        </#if>  
    </tr>
  </#list>
</table>
<br/>

