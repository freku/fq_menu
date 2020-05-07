window.onload = function(e) {
    // $('#main').hide();
    var isShown = false;
    var audioEl = document.getElementById('audio');
    var currentGangId = 1;
    var currengModelId = 0;
    var num = 0;

    function removeMsg(n) {
    	setTimeout(
        	() => $("p[test='" + n +"']").remove()
        , 2500);
    }

    window.addEventListener("message", (event) => {
        var item = event.data;
        if (item !== undefined) {
            switch(item.type) {
                case 'ON_STATE':
                    if(item.display === true) {
                        $('#main').show();
                        isShown = true;
                        currentGangId = 1;
                        audioEl.play();
                    } else {
                        $('#main').hide();
                        isShown = false;
                        audioEl.pause();
                    }
                    break;
                case 'ON_UPDATE_INFO':
                    // if (item.info !== undefined) {
                    var max = 8;
                    $('.pl-num-span').text('0/32 online!');
                    $('.gang-num.vagos').text(item.info.gangs[2] + '/' + max);
                    $('.gang-num.family').text(item.info.gangs[1] + '/' + max);
                    $('.gang-num.ballas').text(item.info.gangs[0] + '/' + max);
                    $('.gang-num.triads').text(item.info.gangs[3] + '/' + max);

                        // item.info.gangs[0]
                    // }
                    break;
                case 'ON_NOTOFICATION':
                    if (item.msg !== undefined) {
                        var el = $('<p></p>').text(item.msg).attr('test', num);
        
                        $('.nots-box').prepend(el);
                        
                        removeMsg(num)
                        num++;
                    }
                    break;
                case 'ON_MODEL_NEXT':
                    if (item.id !== undefined) {
                        currengModelId = parseInt(item.id);
                    }

                    if (currengModelId == 5) {
                        $('#vip-div').show();
                    } else {
                        $('#vip-div').hide();
                    }

                    break;
                default:
                    break;
            }
        }
    })

    $('.start-btn').click(function(){
        if (isShown) {
            $.post('http://fq_menu/menuResult', JSON.stringify({
                type: 'ON_TRY_JOIN',
                gangId: currentGangId,
            }));
        }
    });

    $('.arrow').click(function(){
        if (isShown) {
            if ($(this).hasClass('left')) {
                $.post('http://fq_menu/menuResult', JSON.stringify({
                    type: 'ON_MODEL_CHANGE',
                    direction: -1
                }));
            } else {
                $.post('http://fq_menu/menuResult', JSON.stringify({
                    type: 'ON_MODEL_CHANGE',
                    direction: 1
                }));
            }
        }
    });

    $('.gang-element').click(function(){
        if (isShown) {
            currentGangId = parseInt($(this).attr('gang-id'))
            $.post('http://fq_menu/menuResult', JSON.stringify({
                type: 'ON_GANG_CHANGE',
                id: parseInt($(this).attr('gang-id'))
            }));
        }
    });
    
    $(document).keydown((event) => {
        if(event.which == 88) {
            if (isShown) {
                $.post('http://tools/getData', JSON.stringify({
                    action: 'CLOSE_UI'
                }));
            }
        }
    });
}