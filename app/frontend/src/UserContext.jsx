import { createContext, useContext, useEffect, useState } from 'react';
import { api } from './api.js';

const UserContext = createContext(null);

function readSaved() {
  try { return Number(localStorage.getItem('moviedb.userId')) || null; } catch { return null; }
}

export function UserProvider({ children }) {
  const [users, setUsers] = useState([]);
  const [userId, setUserIdState] = useState(readSaved);
  const [error, setError] = useState(null);

  useEffect(() => {
    api.users()
      .then((list) => {
        setUsers(list);
        setUserIdState((cur) => (list.some((u) => u.user_id === cur) ? cur : list[0]?.user_id ?? null));
      })
      .catch((e) => setError(e.message));
  }, []);

  function setUserId(id) {
    setUserIdState(id);
    try { localStorage.setItem('moviedb.userId', String(id)); } catch { }
  }

  const user = users.find((u) => u.user_id === userId) || null;
  return (
    <UserContext.Provider value={{ users, user, userId, setUserId, error }}>
      {children}
    </UserContext.Provider>
  );
}

export const useUser = () => useContext(UserContext);
