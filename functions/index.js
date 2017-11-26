const Firestore = require("@google-cloud/firestore");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const moment = require("moment");
admin.initializeApp(functions.config().firebase);

const AVERAGE_TICKET_TIME = 10;

exports.helloWorld = functions.https.onRequest((request, response) => {
  let db = admin.firestore();
  db
    .collection("Queues")
    .doc("4lZC9XqfL13dL7IuHeGz")
    .get()
    .then(res => {
      console.log("data = ", res.data());
    });
  response.send("ok");
  return "Function ended";
});

exports.getTicket = functions.https.onRequest((request, response) => {
  let db = admin.firestore();
  let user_id = request.body.user_id;
  let queue_id = request.body.queue_id;
  db
    .runTransaction(transaction => {
      let queuesQuery = db.collection("Queues").doc(queue_id);

      return transaction.get(queuesQuery).then(res => {
        let promises = [];
        let queue = res.data();
        let ticketNumber = queue.last_ticket_number;
        let currentNumber = 0;

        if (queue.current_ticket_id) {
          let ticketCurrentRef = db
            .collection("Tickets")
            .doc(queue.current_ticket_id);

          return transaction.get(ticketCurrentRef).then(ticketsSnapshot => {
            currentNumber = ticketsSnapshot.data().ticket_number;
            let queueRef = db.collection("Queues").doc(queue_id);
            let updateQueuePromise = transaction.update(queueRef, {
              last_ticket_number: ticketNumber + 1
            });
            promises.push(updateQueuePromise);

            let ticket = createTicketObject(
              currentNumber,
              ticketNumber,
              user_id,
              queue_id
            );
            let ticketsRef = db.collection("Tickets").doc();
            let ticket_id = ticketsRef.id;
            let ticketPromise = transaction.set(ticketsRef, ticket);
            promises.push(ticketPromise);

            let ticketStatusRef = db.collection("TicketStatus").doc(ticket_id);
            let ticketStatusPromise = transaction.set(ticketStatusRef, {
              queue_id,
              ticket_number: ticketNumber,
              status: "pending"
            });
            promises.push(ticketStatusPromise);

            return Promise.all(promises);
          });
        } else {
          let queueRef = db.collection("Queues").doc(queue_id);
          let updateQueuePromise = transaction.update(queueRef, {
            last_ticket_number: ticketNumber + 1
          });
          promises.push(updateQueuePromise);

          let ticket = createTicketObject(
            currentNumber,
            ticketNumber,
            user_id,
            queue_id
          );
          let ticketsRef = db.collection("Tickets").doc();
          let ticket_id = ticketsRef.id;
          let ticketPromise = transaction.set(ticketsRef, ticket);
          promises.push(ticketPromise);

          let ticketStatusRef = db.collection("TicketStatus").doc(ticket_id);
          let ticketStatusPromise = transaction.set(ticketStatusRef, {
            queue_id,
            ticket_number: ticketNumber,
            status: "pending"
          });
          promises.push(ticketStatusPromise);

          return Promise.all(promises);
        }
      });
    })
    .then(() => {
      console.log("Transaction successful");
      response.send("ok");
    })
    .catch(error => {
      console.log("Transaction failed", error);
    });
  return "Function ended";
});
const createTicketObject = (current, ticket, user_id, queue_id) => ({
  approx_call_time: current
    ? moment(new Date())
        .add(AVERAGE_TICKET_TIME * (ticket - current), "minutes")
        .toDate()
    : new Date(),
  user_status: "idle",
  created_at: new Date(),
  ticket_number: ticket,
  user_id,
  queue_id
});

exports.updateTicketTimes = functions.firestore
  .document("TicketStatus/{ticket_id}")
  .onUpdate(event => {
    let db = admin.firestore();
    db
      .runTransaction(transaction => {
        let ticket = null; // updated ticket
        let tickets = null; // all tickets from same queue
        let statuses = null; // all tickets with status=pending
        let ticket_id = event.params.ticket_id;
        let ticketQuery = db.collection("Tickets").doc(ticket_id);
        return transaction
          .get(ticketQuery)
          .then(doc => {
            ticket = doc.data();
            let ticketsQuery = db
              .collection("Tickets")
              .where("queue_id", "==", ticket.queue_id)
              .where("ticket_number", ">", ticket.ticket_number);
            return ticketsQuery.get();
          })
          .then(ticketsSnapshot => {
            tickets = ticketsSnapshot;
            let statusesQuery = db
              .collection("TicketStatus")
              .where("queue_id", "==", ticket.queue_id)
              .where("status", "==", "pending")
              .where("ticket_number", ">", ticket.ticket_number);
            return statusesQuery.get();
          })
          .then(ticketStatusSnapshot => {
            let statuses = ticketStatusSnapshot;
            let promises = [];
            tickets.forEach(ticket => {
              if (findTicketStatus(ticket.ref.id, statuses)) {
                let currectTicket = ticket.data();
                let newTicket = Object.assign({}, currectTicket, {
                  approx_call_time: moment(currectTicket.approx_call_time)
                    .subtract(AVERAGE_TICKET_TIME, "minutes")
                    .toDate()
                });
                promises.push(transaction.set(ticket.ref, newTicket));
              }
            });

            return Promise.all(promises);
          });
      })
      .then(() => {
        console.log("Transaction Success");
      })
      .catch(err => {
        console.log("Transaction failed", err);
      });
    return "Function successfully executed";
  });

const findTicketStatus = (ticketId, statuses) => {
  let result = false;
  statuses.forEach(status => {
    if (status.ref.id === ticketId) result = true;
  });
  return result;
};
