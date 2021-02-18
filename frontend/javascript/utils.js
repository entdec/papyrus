export const log = process.env.NODE_ENV === 'production' ? function(){} : (message) => {
  console.log('%c Papyrus: ', 'color: white; background-color: #2274A5', message);
};