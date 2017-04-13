package org.openmrs.module.mdrtbregistration.page.controller;

import org.openmrs.Location;
import org.openmrs.api.context.Context;
import org.openmrs.module.mdrtb.service.MdrtbService;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by Dennis Henry
 * Created on 12/14/2016.
 */
public class SearchPageController {
    public String get(
            @RequestParam(value = "phrase", required=false) String phrase,
            PageModel model,
            UiUtils ui) {
        List<Location> locations = Context.getService(MdrtbService.class).getLocationsByUser();
        Collections.sort(locations, new Comparator<Location>() {
            @Override
            public int compare(Location lo1, Location lo2) {
                return lo1.getName().compareTo(lo2.getName());
            }
        });
        model.addAttribute("phrase", phrase);
        model.addAttribute("locations", locations);
        return null;
    }
}
