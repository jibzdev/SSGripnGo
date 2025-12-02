// Import Action Cable using ES module syntax
import { createConsumer } from "@rails/actioncable";
import "@hotwired/turbo-rails";
import "controllers";
import "dashboard";
import "landing";

// Define the global App object
window.App = {}
window.App.cable = createConsumer("/cable");
