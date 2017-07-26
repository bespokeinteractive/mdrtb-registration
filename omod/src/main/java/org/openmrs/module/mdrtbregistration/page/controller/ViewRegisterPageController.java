package org.openmrs.module.mdrtbregistration.page.controller;

import org.openmrs.Location;
import org.openmrs.api.context.Context;
import org.openmrs.module.mdrtb.service.MdrtbService;
import org.openmrs.ui.framework.page.PageModel;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by Dennis Henry
 * Created on 7/25/2017.
 */
public class ViewRegisterPageController {
    public void get(PageModel model) {
        List<Location> locations = Context.getService(MdrtbService.class).getLocationsByUser();
        Collections.sort(locations, new Comparator<Location>() {
            @Override
            public int compare(Location lo1, Location lo2) {
                return lo1.getName().compareTo(lo2.getName());
            }
        });
        model.addAttribute("locations", locations);
    }
}
