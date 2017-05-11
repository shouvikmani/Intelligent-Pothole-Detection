from django.conf.urls import include, url

from django.contrib import admin
admin.autodiscover()

import app.views

# Examples:
# url(r'^$', 'gettingstarted.views.home', name='home'),
# url(r'^blog/', include('blog.urls')),

urlpatterns = [
    url(r'^$', app.views.index, name='index'),
    url(r'^classifyPotholes', app.views.classifyPotholes, name='classifyPotholes'),
    url(r'^classifyRoadConditions', app.views.classifyRoadConditions, name='classifyRoadConditions'),
    url(r'^admin/', include(admin.site.urls)),
]
