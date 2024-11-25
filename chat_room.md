# **Homework Assignment: Chat Room System with GenServers**

## **Objective**
In this assignment, you’ll create a basic chat room system using Elixir’s GenServer module. Each chat room will operate
as a separate GenServer process, allowing users to join rooms, leave rooms, send messages, and view chat histories.
Additionally, a central server will manage all chat rooms, enabling users to create rooms, list available rooms, and
interact with individual chat rooms.

## **Requirements**

### 1. **ChatRoom Module**
   Implement a `ChatRoom` module that uses GenServer to represent a single chat room. Each chat room should support:
   - **User Management**: Users should be able to join and leave the room. Keep track of users currently in the room.
   - **Messaging**: Users should be able to send messages to the chat room. Each message should include the sender’s name and a timestamp.
   - **Message History**: Maintain a history of messages sent to the chat room, which can be retrieved on request.

### 2. **ChatServer Module**
   Implement a `ChatServer` module that manages all active chat rooms. The `ChatServer` should:
   - **Create and Manage Chat Rooms**: Provide a way to create new chat rooms, each identified by a unique name.
   - **List Available Rooms**: Allow users to view a list of all active chat rooms.
   - **Route Messages and Fetch History**: Enable users to send messages to specific rooms and retrieve the message history of a given room.

### 3. **Edge Cases and Error Handling**
   Ensure that your system handles various edge cases, such as:
   - Attempting to join a non-existent room.
   - Sending messages to a room that the user has not joined.
   - Handling multiple users interacting with the same room simultaneously.

## **Additional Notes**
- Use `start_link` for both ChatRoom and ChatServer modules to ensure they run as supervised processes.
- Keep the functions in `ChatServer` simple by using it primarily as a coordinator for interactions between users and rooms.
- Document your code with function headers that briefly describe each function’s purpose.

## **Example Use Cases**
Consider the following scenarios:
- **Room Creation**: A user creates a chat room called “elixir_room.”
- **Joining and Messaging**: Several users join “elixir_room,” send messages, and then retrieve the chat history.
- **Room Management**: Users list all active rooms and interact with multiple chat rooms simultaneously.

## **Testing**
Write tests to verify that:
- Users can successfully join and leave rooms.
- Messages are stored with timestamps and can be retrieved in the correct order.
- Edge cases (such as trying to join a room that doesn’t exist) are handled gracefully.

