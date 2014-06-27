#include "unitysystemtray.h"

#include <QCoreApplication>

#undef signals
extern "C" {
  #include <libappindicator/app-indicator.h>
  #include <gtk/gtk.h>
}
#define signals public

void quitIndicator(GtkMenu *menu, gpointer data);

class UnitySystemTrayPrivate
{
public:
    AppIndicator *indicator;

    GtkWidget *menu;

    QHash<void*, QPair<QObject*,QString> > items;
};

UnitySystemTray::UnitySystemTray(const QString & name, const QString & icon)
{
    p = new UnitySystemTrayPrivate;

    p->menu = gtk_menu_new();
    p->indicator = app_indicator_new(name.toUtf8(), icon.toUtf8(), APP_INDICATOR_CATEGORY_APPLICATION_STATUS);

    app_indicator_set_status(p->indicator, APP_INDICATOR_STATUS_ACTIVE);
    app_indicator_set_menu(p->indicator, GTK_MENU(p->menu));
}

QHash<void*,QPair<QObject*,QString> > UnitySystemTray::items() const
{
    return p->items;
}

void UnitySystemTray::addMenu( const QString & text, QObject *obj, const char *member )
{
    GtkWidget *item = gtk_menu_item_new_with_label(text.toUtf8());
    gtk_menu_shell_append(GTK_MENU_SHELL(p->menu), item);
    g_signal_connect(item, "activate", G_CALLBACK(quitIndicator), this);
    gtk_widget_show(item);

    p->items[item] = QPair<QObject*,QString>(obj,member);
}

void UnitySystemTray::setIcon(const QString &icon)
{
    app_indicator_set_icon( p->indicator, icon.toUtf8() );
}

UnitySystemTray::~UnitySystemTray()
{
    delete p;
}

void quitIndicator(GtkMenu *menu, gpointer data) {
    UnitySystemTray *self = static_cast<UnitySystemTray *>(data);

    const QPair<QObject*,QString> & pair = self->items().value(menu);
    QMetaObject::invokeMethod( pair.first, pair.second.toUtf8() );
}
