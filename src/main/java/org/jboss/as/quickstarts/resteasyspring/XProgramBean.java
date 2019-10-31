package org.jboss.as.quickstarts.resteasyspring;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.function.Consumer;

public class XProgramBean {

    private String workDirPath;
    private String programToRun;
    private boolean isWindows;

    public XProgramBean(String workDirPath, String programToRun) {
        this.workDirPath = workDirPath;
        this.programToRun = programToRun;
        this.isWindows = System.getProperty("os.name").toLowerCase().startsWith("windows");
    }

    public String process(String request) {
        StringBuilder result = new StringBuilder();
        try {
            ProcessBuilder builder = new ProcessBuilder();
            if (isWindows) {
                builder.command("cmd.exe", "/c", programToRun);
            } else {
                builder.command("sh", "-c", programToRun);
            }
            builder.directory(new File(workDirPath));

            System.out.println("Work directory: " + workDirPath);
            System.out.println("Command: " + String.join(" ", builder.command()));

            Process process = builder.start();
            PrintWriter pw = new PrintWriter(process.getOutputStream());
            pw.write(request);
            pw.write("\n");
            pw.flush();

            StreamGobbler streamGobbler = new StreamGobbler(process.getInputStream(), str -> {
                System.out.println(str);
                result.append(str).append("\n");
            });
            streamGobbler.run();

            int exitCode = process.waitFor();
            System.out.println("Exit code: " + exitCode);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result.toString();
    }

    private static class StreamGobbler {
        private InputStream inputStream;
        private Consumer<String> consumer;

        public StreamGobbler(InputStream inputStream, Consumer<String> consumer) {
            this.inputStream = inputStream;
            this.consumer = consumer;
        }

        public void run() {
            new BufferedReader(new InputStreamReader(inputStream)).lines().forEach(consumer);
        }
    }
}
