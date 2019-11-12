package org.jboss.as.quickstarts.resteasyspring;

import javax.ws.rs.Consumes;
import javax.ws.rs.FormParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;

import org.springframework.beans.factory.annotation.Autowired;

@Path("/")
public class XProgramSpringResource {

    @Autowired
    XProgramBean xProgramBean;

    @GET
    @Path("xprogram")
    @Produces("text/plain")
    public Response getXProgram(@QueryParam("q") String query) {
        String result = xProgramBean.process(query);
        return Response.ok(result).build();
    }

    @POST
    @Path("xprogram")
    @Consumes("text/plain")
    @Produces("text/plain")
    public Response postXProgram(String body) {
        String result = xProgramBean.process(body);
        return Response.ok(result).build();
    }

    @PUT
    @Path("xprogram")
    @Consumes("text/plain")
    @Produces("text/plain")
    public Response putXProgram(String body) {
        String result = xProgramBean.process(body);
        return Response.ok(result).build();
    }

    @DELETE
    @Path("xprogram")
    @Consumes("text/plain")
    @Produces("text/plain")
    public Response deleteXProgram(String body) {
        String result = xProgramBean.process(body);
        return Response.ok(result).build();
    }

    @POST
    @Path("/xprogram-form")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    public Response postXProgramForm(@FormParam("msg") String msg) {
        String result = xProgramBean.process(msg);
        return Response.ok(result).build();
    }
}
