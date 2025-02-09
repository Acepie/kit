package proc

import "sync"

var locks = &sync.Map{}

// KeyLock return a mutex for the key.
// This func never frees un-locked mutexes. It is only suitable for use-cases with a small number of keys.
func KeyLock(key string) *sync.Mutex {
	actual, _ := locks.LoadOrStore(key, &sync.Mutex{})
	mutex := actual.(*sync.Mutex)
	return mutex
}
