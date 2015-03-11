----------------------------------------------
-- implements a new endpoint '/indexes'
-- which returns the air quality indexes
-- for London in a simplified format
----------------------------------------------
return function(request, next_middleware)

  if (request.uri == '/indexes') then
    request.uri = '/Hourly/MonitoringIndex/GroupName=London/Json'
  else
    return next_middleware()
  end

  local response = next_middleware()
  local hourly = json.decode(response.body)
  local lauths = hourly.HourlyAirQualityIndex.LocalAuthority
  local newresponse = {}

  for i=1,#lauths do

    local lauth = lauths[i]

    if lauth.Site then

      for j=1,#lauth.Site do

        local site = lauth.Site[j]

        local sitetable = {
          lat         = site["@Latitude"],
          lng         = site["@Longitude"],
          siteCode    = site["@SiteCode"],
          siteName    = site["@SiteName"],
          siteType    = site["@SiteType"],
          isActive    = site[""],
          indexes     = {}
        }

        if site.Species then

          for k=1,#site.Species do

            local species = site.Species[k]

            local index = {
              airQualityBand          = species["@AirQualityBand"],
              airQualityIndex         = species["@AirQualityIndex"],
              measurementType         = species["@SpeciesCode"],
              measurementDescription  = species["@SpeciesDescription"]
            }

            table.insert(sitetable.indexes, index)

          end

        end

        table.insert(newresponse, sitetable)

      end

    end

  end

  response.body = json.encode(newresponse)

  return response

end
