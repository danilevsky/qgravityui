WorkerScript.onMessage = function(msg) {
    if(msg.action === 'append_icons')
    {
        for(var i = 0; i < msg.icons.length; i++)
        {
            var iconName = msg.icons[i];
            msg.model.append({"name":iconName})
        }

        msg.model.sync();
    }
 }