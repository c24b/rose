var $ = require('jquery-patterns');

var Storage = require('./storage');

/**
* @module Core
* @submodule Observer Engine
*/
var ObserverEngine = (function($) {
    var ObserverEngine = {};

    var observers = [];

    /**
    * Adds an observer to the engine.
    *
    * @method add
    * @param {Object} observer The observer to be added
    */
    ObserverEngine.add = function add(observer) {
        log('ObserverEngine', 'Add observer: ' + observer.name);

        // Push to observers list
        observers.push(observer);
    };

    /**
    * Sets up event listeners and integrates observers
    * into the document.
    *
    * @method register
    */
    ObserverEngine.register = function register() {
        log('ObserverEngine', 'Register in document');

        // Network identifiers
        var identifiers = {
            facebook: 'facebook.com',
            gplus: 'plus.google.com'
        };

        // Determine if user is on network
        var network = null;
        for (var name in identifiers) {
            var url = identifiers[name];

            if ((window.location + '').indexOf(url) >= 0) {
                // Set network and break
                network = name;
                break;
            }
        }

        // If no network has been detected...
        if (network === null) {
            return;
        }

        log('ObserverEngine', 'Integrate into network: ' + network);

        // Register global click event listener
        $(document).on('click', function(event) {
            // Get event target
            var target = event.target;

            // Build path to node
            var path = [target.nodeName];
            $(target).parents().each(function() {
                path.unshift($(this)[0].nodeName);
            });
            path = path.join(' > ');

            // Apply observers
            for (var i in observers) {
                var observer = observers[i];

                // Continue if observer belongs to wrong network
                if (observer.network !== network) {
                    continue;
                }

                // Flag if pattern matches
                var found = false;

                // Data container
                var data = null;

                // Only apply pattern observers at this point
                if (observer.type === 'pattern') {
                    // Go through DOM tree and try to apply pattern
                    for (var node = $(target); node.prop('tagName').toLowerCase() !== 'body'; node = node.parent()) {
                        // Use every pattern
                        for (var j in observer.patterns) {
                            var entry = observer.patterns[j];

                            // Apply pattern
                            var result = node.applyPattern({
                                structure: entry.pattern
                            });

                            // If result found...
                            if (result.success) {
                                // ... store it
                                data = entry.process(result.data);

                                // Set flag and break
                                found = true;
                                break;
                            }
                        }

                        // Something found? Break.
                        if (found) {
                            break;
                        }
                    }
                }

                if (found && data !== null) {
                    // Save interaction to storage
                    Storage.add({
                        type: 'interaction',
                        name: observer.name,
                        network: observer.network,
                        record: data
                    });

                    break;
                }
            }
        });
    };

    return ObserverEngine;
})($);

module.exports = ObserverEngine;