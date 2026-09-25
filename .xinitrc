#!/bin/sh

# Export environment variables for IBus
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus

# Start the D-Bus session bus if not already managed by system
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax --exit-with-session)
fi

# Start IBus daemon in the background
#ibus-daemon -drxR

# Launch dwm within the D-Bus session context
exec dbus-run-session dwm

