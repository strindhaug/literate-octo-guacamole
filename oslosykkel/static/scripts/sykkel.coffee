window.strindhaug ?= {}

# Comment out util functions I'm not using in this file. (It marginally reduces the filesize)

# elByTag = window.strindhaug.elByTag
elById = window.strindhaug.elById
# elByClass = window.strindhaug.elByClass
# elByQuery = window.strindhaug.elByQuery
observe = window.strindhaug.observe
# observeMulti = window.strindhaug.observeMulti
newEl = window.strindhaug.newEl
# doAjax = window.strindhaug.doAjax
# setCookie = window.strindhaug.setCookie
# getCookie = window.strindhaug.getCookie
# deleteCookie = window.strindhaug.deleteCookie

# ----------------

relevant_data_map = {}

sort_station_by_name = (a,b) ->
  return a.name.localeCompare(b.name)

sykkel_setup = ->
    try
      sysinfo = JSON.parse(elById('data-sysinfo').textContent)
      status = JSON.parse(elById('data-status').textContent)
      info = JSON.parse(elById('data-info').textContent)
    catch error
      console.error("Json parsing failed: ", error)
      elById('sykkel_tab_body').innerHTML = """
        <tr><td colspan="4" class="col-center">Noe gikk galt, prøv igjen litt senere.</td></tr>
      """
      return

    frag = document.createDocumentFragment()

    # create id to status mapping
    for s in status?.data?.stations
      relevant_data_map[s.station_id] = {
        num_bikes_available: s.num_bikes_available,
        num_docks_available: s.num_docks_available,
      }

    # sort list of stations alphabetically by name
    sorted = info?.data?.stations.sort(sort_station_by_name)

    for s in sorted
      # for each station look up status data by id and print
      if relevant_data_map.hasOwnProperty(s.station_id)
        tr = newEl("tr", "", """
          <td class="col-text">#{s.name}</td>
          <td class="col-number">#{relevant_data_map[s.station_id].num_docks_available}</td>
          <td class="col-number">#{relevant_data_map[s.station_id].num_bikes_available}</td>
          <td></td>
        """)
        frag.appendChild(tr)
      else
        # inconsistent data, status mapping is missing a station key
        console.warn("Didn't find status data for id #{s.station_id} (#{s.name})")

        tr = newEl("tr", "warn", """
          <td class="col-text">#{s.name}</td>
          <td class="col-number">?</td>
          <td class="col-number">?</td>
          <td class="col-center error">Mangler data</td>
        """)
        frag.appendChild(tr)
        # (There is no test to check if there are statuses with no corresponding station info)

    sykkel_tab_body = elById('sykkel_tab_body')
    sykkel_tab_body.innerHTML = ""
    sykkel_tab_body.appendChild(frag.cloneNode(true))

    last_updated = new Date(status.last_updated * 1000)

    # Show when data was last updated
    elById('status_display').innerHTML = "Data fra #{sysinfo.data.name}. <br>Sist oppdatert: #{last_updated}"


observe(document, "DOMContentLoaded", (event) ->
    console.info("sykkel INIT")
    sykkel_setup()
)
