/* *
* @return a namespace-like object containing functions (show, hide, filterKey)
* allowing to show, hide, and keyboard-navigate into a context menu build from
* the container element given by the selector "menuSelector"
* this
* The container's child of class "itemSelector" are used as selectable menu entries
*
* • WARNING: today's implementation do not take into account adding/removing
*              of items inside the container ...
*/
/*TODO:
_   react to keyboard for navigation inside the menu
*/
function initContextMenu( menuSelector, itemSelector )
{
    const $menu = $(menuSelector);

    var opened = false;


    //object with accessible function properties to be returned to the caller
    const functions = {
        show:
        function(ev)
        {
            opened = true;

            width = $menu.width();
            height = $menu.height();

            //maximum visible coordinate in page referential
            maxX = window.innerWidth + $(document).scrollLeft();
            maxY = window.innerHeight + $(document).scrollTop() -16;

            x = ( (ev.pageX + width) <= maxX ) ?
                    ev.pageX  :  maxX - width;
            y = ( (ev.pageY + height) <= maxY ) ?
                    ev.pageY  :  maxY - height;

            $menu.css('left', x);
            $menu.css('top', y);
            $menu.css('display', 'block');
        },


        hide:
        function()
        {
            if (opened)
            {
                opened = false;
                $menu.css('display', 'none');
            }
        },


        /**
         * consume the keys it need to;
         * @return bool    true if the key was handled by the menu,
         *                 false otherwise
        */
        filterKey:
        function(ev)
        {
            // react to the "menu" key
            if ( ev.which == 93 ) {
                if (opened)
                    this.hide();
                else
                    this.show(ev);

                ev.preventDefault();
                return true;
            }

            //every other key act on opened menu only
            if (!opened)
                return false;

            switch (ev.which) {
                case 27:  //escape key
                    this.hide();
                    break;

                //any unhandled key is catched here
                default:
                    return false;
            }

            ev.preventDefault();
            return true;
        }

    };/* const functions = {...} */


    /* function body */

    $(itemSelector).click(function () {
        functions.hide();
    });

    return functions;
};
