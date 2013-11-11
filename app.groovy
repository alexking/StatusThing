/**
 *  StatusThing 
 *
 *  Author: alexking@me.com
 *  Date: 2013-11-01
 */
preferences {
	section("Settings") {
		input "switches", "capability.switch", title : "Switches", multiple : true, required : true
        input "temp", "capability.temperatureMeasurement", title : "Temperature", multiple : false, required : true
	}
}

mappings 
{
	path("/updateItemsAndTemperature") 
    {
    	action : 
        [
        	GET : "updateItemsAndTemperature"
        ] 
    }
    
    path("/itemChangeToState/:id/:state")
    {
    	action : 
        [
        	GET : "itemChangeToState"
        ]
    }
}


def updateItemsAndTemperature()
{
    def items = []
    for (item in switches)
    {
        items << [ 'id' : item.id , 'state' : item.currentState('switch').value , 'name' : item.displayName ]
    }

    [ 'temp' :  temp.currentValue('temperature') , 'items' : items ]

}

def itemChangeToState()
{

    def item = switches.find { it.id == params.id }

    if (params.state == "on")
    {
        item.on();
    } else {
        item.off();
    }


    def data = updateItemsAndTemperature()

    for(dataItem in data['items']) 
    {
        if (dataItem.id == params.id)
        {
            dataItem.state = params.state; 
        }

    }

    data

}

def installed() { }

def updated() { }