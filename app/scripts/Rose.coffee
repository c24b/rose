###
ROSE is a browser extension researchers can use to capture in situ
data on how users actually use the online social network Facebook.
Copyright (C) 2013

    Fraunhofer Institute for Secure Information Technology
    Andreas Poller <andreas.poller@sit.fraunhofer.de>

Authors

    Oliver Hoffmann <oliverh855@gmail.com>
    Sebastian Ruhleder <sebastian.ruhleder@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

require 'FacebookUI'
require 'Heartbeat'
require 'Management'
require 'Networks/Facebook'
require 'Networks/GooglePlus'

class @Rose
    @mutationObserver: null
    @facebookUI: null

    @startedHeartbeats: []

    @startRose: ->
        # Initialize Management.
        Management.initialize()

        # Get list of networks.
        networks = Management.getListOfNetworks()

        startRose = false
        for network in networks
            startRose = true if network.isOnNetwork()

        return unless startRose

        @facebookUI = new FacebookUI()

        # Set event handling.
        Rose.mutationObserver = new MutationObserver () ->
            Rose.integrate()

        # Start observation.
        Rose.mutationObserver.observe document, {
            subtree:       true,
            childList:     true,
            characterData: true
        }

        # Apply extractors for each network.
        for network in networks
            return unless network.isOnNetwork()
            # Start heartbeat for network, if necessary.
            @startHeartbeat(network)

            # Apply extractors.
            network.applyExtractors()

        # Integrate into site.
        Rose.integrate()

    @startHeartbeat: (network) ->
        return unless network.isOnNetwork()

        name = network.getNetworkName()

        # Create ticker function.
        ticker = ->
            Heartbeat.setHeartbeat(name)

        Storage.getLastOpenCloseInteractionType(name)
        .then((type) ->
            switch type
                when null
                    interaction =
                        type: 'open'
                        time: new Date().toJSON()
                    Storage.addInteraction interaction, name
                when 'open'
                    Heartbeat.getHeartbeat(name)
                    .then((time) ->
                        return unless time?
                        return if time.getTime() + Constants.getOpenCloseInterval() > new Date().getTime()

                        interaction =
                            type: 'close'
                            time: new Date(time.getTime() + Constants.getOpenCloseInterval()).toJSON()
                        Storage.addInteraction(interaction, name)
                        .then(->
                            interaction =
                                type: 'open'
                                time: new Date().toJSON()
                            Storage.addInteraction interaction, name
                        )
                    )
                when 'close'
                    interaction =
                        type: 'open'
                        time: new Date().toJSON()
                    Storage.addInteraction interaction, name
        )

        setInterval(ticker, Constants.getHeartbeatDelay())

    @integrate: ->
        # Get list of networks.
        networks = Management.getListOfNetworks()

        # Integrate networks, if possible.
        for network in networks
            # Continue unless applicable.
            continue unless network.isOnNetwork()

            # Apply observers.
            network.applyObservers()

            # Integrate into DOM.
            network.integrateIntoDOM()

        @facebookUI.redrawUI()
