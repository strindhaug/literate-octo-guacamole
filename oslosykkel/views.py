from django.shortcuts import render
from django.core.cache import cache
import requests


def get_data():

    # Identify myself to the remote:
    headers = {'Client-Identifier': 'strindhaug-oslosykkel-test-app'}

    # Cache for 30 seconds not to flood the remote

    sysinfo = cache.get('sysinfo')
    station_status = cache.get('station_status')
    station_info = cache.get('station_info')

    if not sysinfo:
        sysinfo_r = requests.get('http://gbfs.urbansharing.com/oslobysykkel.no/system_information.json', headers=headers)
        sysinfo = sysinfo_r.json()
        cache.set('sysinfo', sysinfo, 30)
    if not station_status:
        station_status_r = requests.get('http://gbfs.urbansharing.com/oslobysykkel.no/station_status.json', headers=headers)
        station_status = station_status_r.json()
        cache.set('station_status', station_status, 30)
    if not station_info:
        station_info_r = requests.get('http://gbfs.urbansharing.com/oslobysykkel.no/station_information.json', headers=headers)
        station_info = station_info_r.json()
        cache.set('station_info', station_info, 30)

    context = {
        #  Unncomment for raw text response while debugging
        # "sysinfo_txt": sysinfo_r.text,
        # "station_status_txt": station_status_r.text,
        # "station_info_txt": station_info_r.text,

        # The response parsed as json into python dicts:
        "sysinfo": sysinfo,
        "station_status": station_status,
        "station_info": station_info,
    }
    return context


def overview(request):
    context = get_data()

    return render(request, "oslosykkel/overview.html", context)
